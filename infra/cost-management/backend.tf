terraform {
  backend "s3" {
    key          = "cost-management/terraform.tfstate"
    use_lockfile = true
  }
}
