from django.urls import include, path

from api import urls as api_urls

urlpatterns = [
    # 認証なし(ALBの /api/* ルール)
    path("api/", include(api_urls.public_urlpatterns)),
    # Cognito C認証あり(ALBの /c/booking/api/*・/c/mypage/api/* ルール)
    path("c/booking/api/", include(api_urls.booking_urlpatterns)),
    path("c/mypage/api/", include(api_urls.mypage_urlpatterns)),
]
