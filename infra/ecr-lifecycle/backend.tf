terraform {
  backend "s3" {
    key          = "ecr-lifecycle/terraform.tfstate"
    use_lockfile = true
  }
}
