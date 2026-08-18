terraform {
  backend "s3" {
    key          = "database/terraform.tfstate"
    use_lockfile = true
  }
}
