# docs/architecture/

tour-bookingのAWSアーキテクチャを、サービス単位で設計・記録する。

着手したサービスから`templates/design-doc-template.md`を使って`docs/architecture/<サービス名>.md`を作成し、下表にリンクを追加する。

## 全体構成図

Step2〜8の全体構成図は[overall.drawio.png](overall.drawio.png)を参照。PNG形式だが、draw.io(app.diagrams.net)の元データを埋め込んだ状態でエクスポートしているため、同ツールで開けばそのまま編集できる。

## サービス一覧

| サービス | 状態 | ドキュメント |
|---|---|---|
| ネットワーク | 構築中 | [network.md](network.md) |
| セキュリティグループ | 構築中 | [security-group.md](security-group.md) |
| ALB | 構築中 | [alb.md](alb.md) |
| Cognito | 構築中 | [cognito.md](cognito.md) |
| データベース | 完了 | [database.md](database.md) |
| CI/CD | 構築中 | [ci-cd.md](ci-cd.md) |

状態の値は「設計中 / 設計レビュー待ち / 設計差し戻し中 / 構築中 / 実装レビュー待ち / 完了」(`templates/design-review-template.md`の運用に準じる)。

## レビュー記録

設計・実装レビューの記録は[docs/reviews/](../reviews/)にまとめる。
