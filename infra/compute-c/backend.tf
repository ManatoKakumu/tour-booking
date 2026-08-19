terraform {
  backend "s3" {
    key          = "compute-c/terraform.tfstate"
    use_lockfile = true
  }
}
