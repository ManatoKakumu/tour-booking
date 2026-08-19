terraform {
  backend "s3" {
    key          = "compute-b/terraform.tfstate"
    use_lockfile = true
  }
}
