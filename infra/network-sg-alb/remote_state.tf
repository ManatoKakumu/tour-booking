variable "tfstate_bucket" {
  type = string
}

data "terraform_remote_state" "cloudfront_route53_acm_s3" {
  backend = "s3"
  config = {
    bucket = var.tfstate_bucket
    key    = "cloudfront-route53-acm-s3/terraform.tfstate"
    region = "ap-northeast-1"
  }
}
