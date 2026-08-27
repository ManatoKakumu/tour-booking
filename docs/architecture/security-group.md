# セキュリティグループ

## 要件・前提
- ALB
  - Inbound：CloudFront
  - Outbound：ECS(フロント・API)
- ECS(フロント)
  - Inbound：ALB
  - Outbound：VPCエンドポイント(ecr.api/ecr.dkr/logs), S3(Gateway経由)
- ECS(API)
  - Inbound：ALB
  - Outbound：RDS, VPCエンドポイント(ecr.api/ecr.dkr/logs), S3(画像用バケット, Gateway経由), NAT Gateway経由で外部API呼び出し
- RDS
  - Inbound：ECS(API)
  - Outbound：なし。プライマリ - スタンバイ間の同期処理はSGの設定にかかわらずAWSが内部で自動的に処理するため、RDSは特に付与する必要はない
- VPCエンドポイント(Interface型)
  - Inbound：ECS(フロント・API)
  - Outbound：なし

## 設計

### 構成図

- [docs/architecture/README.md](README.md)参照

### 設計方針
- `要件・前提` に記載の内容を、SG参照をベースに許可ルールを追加する
  - SG参照にするのは、IPアドレス(CIDR)指定だと、ECSなどのスケーリングでIPアドレスが変更されるため、通信を維持するには広めのCIDRにしなければならない。ただそうすると不必要に大きな範囲を許可しかねないので、SG参照にすることで、SG付与されているリソースとの通信のみに絞ることが可能
  - Outboundはデフォルトで全通信を許可しているが、必要な通信のみを許可する、最小権限の原則を反映した形で進める
- ECS(API)の外部API呼び出しの絞り込み方針
  - Stripeが公開している、API通信用のIPアドレス一覧を参照する
  - IPアドレス一覧をマネージドプレフィックスリストに登録する
  - ECS(API)のSGに、Outboundでプレフィックスリストを許可するルールを追加する
  - IPアドレス変更に備え、Lambdaで手動実行する [docs/adr/005-stripe-ip-sync-trigger-selection.md](../adr/005-stripe-ip-sync-trigger-selection.md)参照
