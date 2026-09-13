variable "tfstate_bucket" {
  type = string
}

data "terraform_remote_state" "compute_b" {
  backend = "s3"
  config = {
    bucket = var.tfstate_bucket
    key    = "compute-b/terraform.tfstate"
    region = var.default_region
  }
}

data "terraform_remote_state" "compute_c" {
  backend = "s3"
  config = {
    bucket = var.tfstate_bucket
    key    = "compute-c/terraform.tfstate"
    region = var.default_region
  }
}
