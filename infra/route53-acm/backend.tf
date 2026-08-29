terraform {
  backend "s3" {
    key          = "route53-acm/terraform.tfstate"
    use_lockfile = true
  }
}
