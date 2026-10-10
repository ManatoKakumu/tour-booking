import json
from functools import wraps

from django.http import JsonResponse

from .auth import AuthenticationError, get_authenticated_sub


def json_response(data, status=200):
    response = JsonResponse(data, status=status, json_dumps_params={"ensure_ascii": False})
    # CloudFrontのデフォルトTTLでAPIレスポンスがキャッシュされないようにする
    response["Cache-Control"] = "no-store"
    return response


def error(message, status):
    return json_response({"error": message}, status=status)


def parse_json(request):
    """リクエスト本体をJSONオブジェクト(dict)として読む。不正なJSONやオブジェクト以外はNoneを返す"""
    try:
        body = json.loads(request.body or b"{}")
    except json.JSONDecodeError:
        return None
    return body if isinstance(body, dict) else None


def api_view(methods, auth=True):
    """
    許可メソッドの制限・認証・CSRF対策をまとめたデコレーター。

    認証はALBが発行するセッションCookieに依存するため、状態を変えるリクエストには
    独自ヘッダー(X-Requested-With)を必須にする。独自ヘッダー付きのクロスオリジン
    リクエストはプリフライトが必要になり、CORSを許可していないため他サイトからは送れない。
    """

    def decorator(view):
        @wraps(view)
        def wrapper(request, *args, **kwargs):
            if request.method not in methods:
                return error("method not allowed", 405)
            if request.method != "GET" and request.headers.get("X-Requested-With") != "fetch":
                return error("missing X-Requested-With header", 403)
            if auth:
                try:
                    request.sub = get_authenticated_sub(request)
                except AuthenticationError:
                    return error("unauthorized", 401)
            return view(request, *args, **kwargs)

        return wrapper

    return decorator
