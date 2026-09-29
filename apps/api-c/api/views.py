import logging

from django.conf import settings
from django.db import transaction
from django.utils import timezone

from .capacity import cancel_pending_booking, reserve_seat
from .http import api_view, error, json_response, parse_json
from .models import Booking, Tour
from .payments import create_checkout_session, get_payment_status

logger = logging.getLogger(__name__)


def health(request):
    return json_response({"status": "ok", "service": "api-c"})


def serialize_tour(tour):
    return {
        "id": tour.id,
        "title": tour.title,
        "description": tour.description,
        "price": tour.price,
        "capacity": tour.capacity,
        "remaining": tour.remaining,
        "image_key": tour.image_key,
    }


def serialize_booking(booking):
    return {
        "id": booking.id,
        "tour": {"id": booking.tour_id, "title": booking.tour.title},
        "status": booking.status,
        "amount": booking.amount,
        "created_at": booking.created_at.isoformat(),
    }


# ---- 公開API(/api/*、認証なし) ----


@api_view(["GET"], auth=False)
def public_tours(request):
    return json_response({"tours": [serialize_tour(t) for t in Tour.objects.all()]})


@api_view(["GET"], auth=False)
def public_tour_detail(request, tour_id):
    tour = Tour.objects.filter(pk=tour_id).first()
    if tour is None:
        return error("tour not found", 404)
    return json_response({"tour": serialize_tour(tour)})


# ---- 予約(/c/booking/api/*、Cognito C認証) ----


@api_view(["POST"])
def create_booking(request):
    body = parse_json(request)
    tour_id = (body or {}).get("tour_id")
    # boolはintのサブクラスのため、isinstanceだけではtrue/falseも通ってしまう
    if not isinstance(tour_id, int) or isinstance(tour_id, bool):
        return error("tour_idを指定してください", 400)

    tour = Tour.objects.filter(pk=tour_id).first()
    if tour is None:
        return error("tour not found", 404)

    # 支払わずに予約だけを繰り返して枠を埋める(在庫の買い占め)のを抑えるため、決済待ちは1人1件までにする
    if Booking.objects.filter(traveler_sub=request.sub, status=Booking.Status.PENDING).exists():
        return error("決済待ちの予約があります。決済を完了するか取り消してから予約してください", 409)

    with transaction.atomic():
        if not reserve_seat(tour.id):
            return error("満席のため予約できません", 409)
        booking = Booking.objects.create(tour=tour, traveler_sub=request.sub, amount=tour.price)

    base_url = settings.PUBLIC_BASE_URL
    try:
        session = create_checkout_session(
            booking=booking,
            tour=tour,
            success_url=f"{base_url}/c/booking/complete/?session_id={{CHECKOUT_SESSION_ID}}",
            cancel_url=f"{base_url}/c/booking/cancel/?booking_id={booking.id}",
        )
    except Exception:
        logger.exception("Checkout Sessionの作成に失敗しました booking_id=%s", booking.id)
        cancel_pending_booking(booking.id)
        return error("決済の開始に失敗しました", 502)

    booking.stripe_session_id = session.id
    booking.save(update_fields=["stripe_session_id", "updated_at"])
    return json_response({"booking_id": booking.id, "checkout_url": session.url}, status=201)


@api_view(["POST"])
def confirm_booking(request):
    """Stripe Checkoutから戻ってきた後、Stripe側の支払い状態を確認して予約を確定する"""
    body = parse_json(request)
    session_id = (body or {}).get("session_id")
    if not isinstance(session_id, str) or not session_id:
        return error("session_idを指定してください", 400)

    booking = (
        Booking.objects.select_related("tour")
        .filter(stripe_session_id=session_id, traveler_sub=request.sub)
        .first()
    )
    if booking is None:
        return error("booking not found", 404)

    if booking.status == Booking.Status.PENDING:
        try:
            payment_status = get_payment_status(session_id)
        except Exception:
            logger.exception("支払い状態の取得に失敗しました booking_id=%s", booking.id)
            return error("支払い状態の確認に失敗しました", 502)
        if payment_status == "paid":
            # 同時に取り消された予約を確定で上書きしないよう、決済待ちのものだけを更新する
            Booking.objects.filter(pk=booking.id, status=Booking.Status.PENDING).update(
                status=Booking.Status.CONFIRMED, updated_at=timezone.now()
            )
            booking.refresh_from_db()

    return json_response({"booking": serialize_booking(booking)})


@api_view(["POST"])
def cancel_booking(request, booking_id):
    """決済前(pending)の予約を取り消し、確保していた枠を戻す"""
    booking = Booking.objects.select_related("tour").filter(pk=booking_id, traveler_sub=request.sub).first()
    if booking is None:
        return error("booking not found", 404)
    if booking.status != Booking.Status.PENDING:
        return json_response({"booking": serialize_booking(booking)})

    # 決済完了後にキャンセル画面へ来た場合に取り消してしまわないよう、Stripe側を確認する
    if booking.stripe_session_id:
        try:
            if get_payment_status(booking.stripe_session_id) == "paid":
                return error("支払い済みの予約は取り消せません", 409)
        except Exception:
            logger.exception("支払い状態の取得に失敗しました booking_id=%s", booking.id)
            return error("支払い状態の確認に失敗しました", 502)

    cancel_pending_booking(booking.id)
    booking.refresh_from_db()
    return json_response({"booking": serialize_booking(booking)})


# ---- マイページ(/c/mypage/api/*、Cognito C認証) ----


@api_view(["GET"])
def my_bookings(request):
    bookings = Booking.objects.select_related("tour").filter(traveler_sub=request.sub)
    return json_response({"bookings": [serialize_booking(b) for b in bookings]})
