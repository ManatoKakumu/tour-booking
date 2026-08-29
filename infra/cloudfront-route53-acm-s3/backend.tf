terraform {
  backend "s3" {
    key          = "cloudfront-route53-acm-s3/terraform.tfstate"
    use_lockfile = true
  }
}
