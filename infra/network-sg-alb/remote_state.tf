variable "tfstate_bucket" {
  type = string
}

data "terraform_remote_state" "route53_acm" {
  backend = "s3"
  config = {
    bucket = var.tfstate_bucket
    key    = "route53-acm/terraform.tfstate"
    region = "ap-northeast-1"
  }
}
