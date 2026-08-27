terraform {
  backend "s3" {
    key          = "stripe-ip-sync/terraform.tfstate"
    use_lockfile = true
  }
}
