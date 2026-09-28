import logging

from .http import api_view, error, json_response
from .models import Tour
from .storage import upload_tour_image

logger = logging.getLogger(__name__)

ALLOWED_IMAGE_TYPES = {"image/jpeg", "image/png", "image/webp"}
MAX_IMAGE_BYTES = 5 * 1024 * 1024


def health(request):
    return json_response({"status": "ok", "service": "api-b"})


def serialize_tour(tour):
    return {
        "id": tour.id,
        "title": tour.title,
        "description": tour.description,
        "price": tour.price,
        "capacity": tour.capacity,
        "remaining": tour.remaining,
        "image_key": tour.image_key,
        "created_at": tour.created_at.isoformat(),
    }


def parse_positive_int(value):
    try:
        number = int(value)
    except (TypeError, ValueError):
        return None
    return number if number > 0 else None


@api_view(["GET", "POST"])
def tours(request):
    if request.method == "GET":
        own_tours = Tour.objects.filter(guide_sub=request.sub)
        return json_response({"tours": [serialize_tour(t) for t in own_tours]})

    # POSTは画像を含むためmultipart/form-dataで受け取る
    title = request.POST.get("title", "").strip()
    description = request.POST.get("description", "").strip()
    price = parse_positive_int(request.POST.get("price"))
    capacity = parse_positive_int(request.POST.get("capacity"))
    image = request.FILES.get("image")

    if not title or len(title) > 100:
        return error("titleは1〜100文字で入力してください", 400)
    if price is None or capacity is None:
        return error("price・capacityは1以上の整数で入力してください", 400)
    if image is not None:
        if image.content_type not in ALLOWED_IMAGE_TYPES:
            return error("画像はJPEG・PNG・WebPのみ対応しています", 400)
        if image.size > MAX_IMAGE_BYTES:
            return error("画像は5MB以下にしてください", 400)

    image_key = ""
    if image is not None:
        try:
            image_key = upload_tour_image(image, image.content_type)
        except Exception:
            logger.exception("画像のアップロードに失敗しました")
            return error("画像のアップロードに失敗しました", 502)

    tour = Tour.objects.create(
        guide_sub=request.sub,
        title=title,
        description=description,
        price=price,
        capacity=capacity,
        remaining=capacity,
        image_key=image_key,
    )
    return json_response({"tour": serialize_tour(tour)}, status=201)
