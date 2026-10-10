import os

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
# セッション・CSRFトークン・Django認証を使わないため、署名用途の実害は無い
SECRET_KEY = os.environ.get("DJANGO_SECRET_KEY", "dev-only-placeholder")
DEBUG = os.environ.get("DJANGO_DEBUG") == "1"
ALLOWED_HOSTS = ["*"]

# 認証はALB+Cognitoが担うため、django.contrib.auth等は入れない
INSTALLED_APPS = [
    "api.apps.ApiConfig",
]

MIDDLEWARE = [
    "django.middleware.common.CommonMiddleware",
]
ROOT_URLCONF = "config.urls"
TEMPLATES = []
WSGI_APPLICATION = "config.wsgi.application"

# DB接続情報は環境変数で受け取る(本番はECSタスク定義のsecretsでSecrets Managerから注入)
DATABASES = {
    "default": {
        "ENGINE": "django.db.backends.mysql",
        "NAME": os.environ.get("DB_NAME", "tour_booking"),
        "USER": os.environ.get("DB_USER", ""),
        "PASSWORD": os.environ.get("DB_PASSWORD", ""),
        "HOST": os.environ.get("DB_HOST", ""),
        "PORT": os.environ.get("DB_PORT", "3306"),
        "CONN_MAX_AGE": 60,
        "OPTIONS": {"charset": "utf8mb4"},
    }
}

DEFAULT_AUTO_FIELD = "django.db.models.BigAutoField"
USE_TZ = True
TIME_ZONE = "Asia/Tokyo"

# CloudWatch Logsへ流すため、標準出力にのみ出す
LOGGING = {
    "version": 1,
    "disable_existing_loggers": False,
    "handlers": {"console": {"class": "logging.StreamHandler"}},
    "root": {"handlers": ["console"], "level": "INFO"},
}

# Stripeの戻り先URL(success_url/cancel_url)の組み立てに使う。
# CloudFront経由ではHostヘッダーがオリジンに転送されないため、リクエストからは組み立てない
PUBLIC_BASE_URL = os.environ.get("PUBLIC_BASE_URL", "http://localhost:8080")
