# tour-booking

現地ガイドが提供するツアー・アクティビティを旅行者が予約する、架空の予約プラットフォーム。AWSアーキテクチャの設計・実装スキルを高めることを目的に、個人開発として構築する。実務経験とは切り離したオリジナル設計。

## 決定済みの前提

- 会員機能: 旅行者用アカウント・ガイド用(出品者)アカウントの2種類
- 決済: カード情報は自社で保持せず決済代行(Stripe等)に委託。自社DBには取引ID・ステータス・金額程度の低感度情報のみ保持
- 実装は10ステップ全て行う(一部を後回しにしない方針)。ただし期間の中間地点で進捗チェックポイントを設ける
- 各ステップの完成度基準: 「本人が独力で(助けなしに)設計判断を説明しきれるか」

## アーキテクチャロードマップ(10ステップ)

Well-Architected Frameworkの各柱に対応させた改善ステップ。実装順は必ずしも番号順ではなく、依存関係に応じてまとめて進める(詳細は [docs/architecture/README.md](docs/architecture/README.md))。

| Step | 内容 | Well-Architected対応 |
|---|---|---|
| 1 | DB分離(バルクヘッド) | REL 10 |
| 2 | ALB導入 | REL 2 |
| 3 | NWレイヤー分離 | SEC 5-BP01 |
| 4 | SGの最小権限化 | SEC 5-BP02 |
| 5 | マルチAZ | REL 10-BP05 |
| 6 | Auto Scaling | REL 11 |
| 7 | セッション管理方式の検討(ElastiCache不採用) | PERF 2 |
| 8 | CloudFront + WAF | SEC 5 / PERF 4 |
| 9 | バックアップ・DR(RPO/RTO) | REL 9 / REL 13 |
| 10 | Savings Plans/コスト最適化 | COST 5 / COST 7 |

## 進め方(Claudeとの役割分担)

詳細は [docs/WORKING_AGREEMENT.md](docs/WORKING_AGREEMENT.md)。

- 設計判断(何を作るか・なぜそうするか)は本人が行う。Claudeはソクラテス式の設計レビュー・壁打ち役に徹する
- コード(Terraform・アプリケーション)は自分の手で書く。Claudeに書かせない
- 初めて触る構文は最小サンプルの提示のみ許可(構文と設計判断を混同しない)

## リポジトリ構成

```
tour-booking/
├── README.md
├── docs/
│   ├── WORKING_AGREEMENT.md   # Claudeの役割・レビュー観点・ガードレール
│   ├── architecture/          # AWSサービス単位の設計ドキュメント
│   └── reviews/               # 設計・実装レビューの記録
├── templates/                 # 設計ドキュメント・レビューのテンプレート
└── infra/                     # Terraformコード(サービス単位でディレクトリ・state分割)
```

## 更新履歴

- 2026-07-26: リポジトリの土台を構築
- 2026-08-30: Step2〜8前半の設計・実装が進行中(詳細は[docs/architecture/README.md](docs/architecture/README.md)参照)
