"""
定員(残り枠)の更新処理

画面・予約フローのロジックから独立させ、将来の外部在庫との同期などからも
同じ関数を呼べるようにしている。
"""

from django.db import transaction
from django.db.models import F
from django.utils import timezone

from .models import Booking, Tour


def reserve_seat(tour_id):
    """残り枠を1つ確保する。確保できた場合はTrue、満席(またはツアーが無い)ならFalse"""
    # 条件付きUPDATE1文で「残りを確認して減らす」を行い、同時予約でもマイナスにならないようにする
    updated = Tour.objects.filter(pk=tour_id, remaining__gt=0).update(remaining=F("remaining") - 1)
    return updated == 1


def cancel_pending_booking(booking_id):
    """
    決済待ちの予約を取消にし、取消にできた場合のみ枠を1つ戻す。今回取消にした場合はTrue

    枠を戻すのは予約の状態が変わったときだけに限定するため、_release_seatはここからしか呼ばない。
    同じ予約に対して同時に呼ばれても、状態を変えられるのは1回だけなので枠は二重に戻らない。
    """
    with transaction.atomic():
        # QuerySet.update()ではauto_nowが効かないため、updated_atは明示的に更新する
        updated = Booking.objects.filter(pk=booking_id, status=Booking.Status.PENDING).update(
            status=Booking.Status.CANCELED, updated_at=timezone.now()
        )
        if updated != 1:
            return False
        tour_id = Booking.objects.values_list("tour_id", flat=True).get(pk=booking_id)
        _release_seat(tour_id)
    return True


def _release_seat(tour_id):
    """確保済みの枠を1つ戻す。定員を超えて戻さない"""
    Tour.objects.filter(pk=tour_id, remaining__lt=F("capacity")).update(remaining=F("remaining") + 1)
