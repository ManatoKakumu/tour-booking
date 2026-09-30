from django.urls import path

from . import views

# ALBのリスナールールに合わせてURLプレフィックスごとに分ける(config/urls.py参照)
public_urlpatterns = [
    path("health/", views.health),
    path("tours/", views.public_tours),
    path("tours/<int:tour_id>/", views.public_tour_detail),
]

booking_urlpatterns = [
    path("bookings/", views.create_booking),
    path("bookings/confirm/", views.confirm_booking),
    path("bookings/<int:booking_id>/cancel/", views.cancel_booking),
]

mypage_urlpatterns = [
    path("bookings/", views.my_bookings),
]
