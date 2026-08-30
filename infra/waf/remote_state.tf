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
