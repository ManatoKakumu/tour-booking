terraform {
  backend "s3" {
    key          = "waf/terraform.tfstate"
    use_lockfile = true
  }
}
