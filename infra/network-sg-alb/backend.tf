terraform {
  backend "s3" {
    key          = "network-sg-alb/terraform.tfstate"
    use_lockfile = true
  }
}
