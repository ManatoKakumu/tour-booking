terraform {
  backend "s3" {
    key          = "cloudfront-s3/terraform.tfstate"
    use_lockfile = true
  }
}
