from django.db import models


class Tour(models.Model):
    """api-b側がマイグレーションを管理するtoursテーブルを参照する(api-cでは作成しない)"""

    guide_sub = models.CharField(max_length=64)
    title = models.CharField(max_length=100)
    description = models.TextField(blank=True)
    price = models.PositiveIntegerField()
    capacity = models.PositiveIntegerField()
    remaining = models.PositiveIntegerField()
    image_key = models.CharField(max_length=255, blank=True)
    created_at = models.DateTimeField()

    class Meta:
        managed = False
        db_table = "tours"
        ordering = ["-created_at"]


class Booking(models.Model):
    class Status(models.TextChoices):
        PENDING = "pending"
        CONFIRMED = "confirmed"
        CANCELED = "canceled"

    tour = models.ForeignKey(Tour, on_delete=models.PROTECT, related_name="bookings")
    # 旅行者のCognito User Pool C上のsub
    traveler_sub = models.CharField(max_length=64, db_index=True)
    status = models.CharField(max_length=16, choices=Status.choices, default=Status.PENDING)
    # 予約時点の価格(円)。カード情報等は保持せず、Stripe側のIDと金額のみを持つ
    amount = models.PositiveIntegerField()
    stripe_session_id = models.CharField(max_length=255, unique=True, null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = "bookings"
        ordering = ["-created_at"]
