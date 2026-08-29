variable "tfstate_bucket" {
  type = string
}

data "terraform_remote_state" "network_sg_alb" {
  backend = "s3"
  config = {
    bucket = var.tfstate_bucket
    key    = "network-sg-alb/terraform.tfstate"
    region = "ap-northeast-1"
  }
}

data "terraform_remote_state" "compute_b" {
  backend = "s3"
  config = {
    bucket = var.tfstate_bucket
    key    = "compute-b/terraform.tfstate"
    region = "ap-northeast-1"
  }
}

data "terraform_remote_state" "route53_acm" {
  backend = "s3"
  config = {
    bucket = var.tfstate_bucket
    key    = "route53-acm/terraform.tfstate"
    region = "ap-northeast-1"
  }
}
