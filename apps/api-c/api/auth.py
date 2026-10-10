"""
【本人実装】ALBが付与するCognito認証ヘッダーからのユーザー特定

ALBのauthenticate-cognitoアクションを通過したリクエストには、ALBが以下のヘッダーを付けてターゲットへ転送する。
- x-amzn-oidc-data: ユーザークレームを含むJWT(ALBが署名)
- x-amzn-oidc-identity: ユーザーのsub
- x-amzn-oidc-accesstoken: Cognitoのアクセストークン

x-amzn-oidc-identityを署名検証なしで信頼する。API用SGはALBからの通信しか受け付けないため、
このヘッダーを付けられるのはALBだけ、というネットワーク境界を信頼の根拠にしている。
x-amzn-oidc-dataの署名検証には公開鍵エンドポイントへのegressが必要で、egress制限と衝突するため採用しない。
残るリスク(リスナールールの設定ミスで認証なしのルールに流れた場合のヘッダー偽装)は、
デプロイ後に未ログインで認証ありのパスがCognitoへリダイレクトされることを確認して検知する。
"""

import os

from django.conf import settings


class AuthenticationError(Exception):
    """認証情報が無い・不正な場合に送出する。views側で401に変換する"""


def get_authenticated_sub(request):
    """認証済みユーザーのsubを返す。取得できない場合はAuthenticationErrorを送出する"""
    # ローカル開発用(local/compose.yaml)。DEBUG時のみ固定のsubを返す
    local_sub = os.environ.get("LOCAL_DEV_USER_SUB")
    if settings.DEBUG and local_sub:
        return local_sub

    sub = request.headers.get("x-amzn-oidc-identity")
    if not sub:
        raise AuthenticationError("x-amzn-oidc-identity header is missing")
    return sub
