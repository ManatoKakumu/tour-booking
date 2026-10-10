# static-pages

CloudFrontが静的配信用S3バケットから直接返すページ。CloudFrontのキャッシュビヘイビア(`index.html`・`/about`・`/terms`)とS3のオブジェクトキーの対応は次のとおり。

| ファイル | S3オブジェクトキー | Content-Type |
|---|---|---|
| `index.html` | `index.html` | `text/html; charset=utf-8` |
| `about.html` | `about` | `text/html; charset=utf-8` |
| `terms.html` | `terms` | `text/html; charset=utf-8` |

`about`・`terms`は拡張子無しのキーになるため、アップロード時にContent-Typeを明示する。
