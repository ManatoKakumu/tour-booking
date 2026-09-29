"""
【本人実装】画像用S3バケットへのアップロード

api-bのタスクロール(api-b-task)には、画像用バケットへのs3:PutObjectのみが許可されている。
通信はS3向けGateway型VPCエンドポイント経由になり、エンドポイントポリシーでも制限されている。
"""

import os
import uuid

import boto3

EXTENSIONS = {
    "image/jpeg": "jpg",
    "image/png": "png",
    "image/webp": "webp",
}

# 認証情報は渡さない。ECS上ではタスクロールの一時認証情報をboto3が自動で取得する
s3 = boto3.client("s3")


def upload_tour_image(file, content_type):
    # ファイル名の衝突・上書きを避けるため、ランダムなIDをキーにする
    key = f"images/{uuid.uuid4()}.{EXTENSIONS[content_type]}"
    s3.put_object(
        Bucket=os.environ["IMAGE_BUCKET_NAME"],
        Key=key,
        Body=file,
        ContentType=content_type,
    )
    return key
