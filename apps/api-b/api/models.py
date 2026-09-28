from django.db import models


class Tour(models.Model):
    # ガイドのCognito User Pool B上のsub
    guide_sub = models.CharField(max_length=64, db_index=True)
    title = models.CharField(max_length=100)
    description = models.TextField(blank=True)
    # 円(Stripe上もJPYはゼロ小数通貨)
    price = models.PositiveIntegerField()
    capacity = models.PositiveIntegerField()
    # 予約可能な残り枠。更新はapi-c側の定員更新処理(capacity.py)が担う
    remaining = models.PositiveIntegerField()
    # 画像用S3バケット上のキー(images/...)。CloudFrontの/images/*から配信される
    image_key = models.CharField(max_length=255, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = "tours"
        ordering = ["-created_at"]
