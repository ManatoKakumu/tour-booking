# local

アプリケーションのローカル開発環境。

```sh
docker compose -f local/compose.yaml up --build
```

http://localhost:8080 で、CloudFront+ALBと同じパス構成でアクセスできる。

| パス | 振り分け先 |
|---|---|
| `/`・`/about`・`/terms` | 静的ページ(`apps/static-pages/`) |
| `/b/api/*` | api-b |
| `/b/*` | front-b |
| `/api/*`・`/c/booking/api/*`・`/c/mypage/api/*` | api-c |
| それ以外 | front-c |

## 本番との違い

- Cognito認証は行わない。`DJANGO_DEBUG=1`かつ`LOCAL_DEV_USER_SUB`が設定されている場合のみ、APIは固定のユーザーとして動く
- DBはrootで接続する(B/C別ユーザー・GRANTは再現しない)
- 画像用S3(`/images/*`)は再現しない
- StripeはAPIを実際に呼ぶ。テストモードのシークレットキーを環境変数`STRIPE_SECRET_KEY`で渡す
