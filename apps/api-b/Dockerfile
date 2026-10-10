FROM python:3.12-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
EXPOSE 3000
# ALBの認証セッションCookieは1ユーザー分で約4.4KBあり、B/C両方にログインしたブラウザからは
# 約9KBのCookieヘッダーが届く。gunicornの既定の上限(1ヘッダー8190バイト)を超えると431に
# なるため、上限を広げる
CMD ["gunicorn", "config.wsgi:application", "--bind", "0.0.0.0:3000", "--limit-request-field_size", "16384"]
