locals {
  region  = "us-east-1"
  profile = "terraform-private-aws"
}

generate "backend" {
  path      = "backend.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
terraform {
  backend "s3" {
    bucket         = "nshavandin-eks-tfstate"
    key            = "${path_relative_to_include()}/tofu.tfstate"
    region         = "${local.region}"
    profile = "${local.profile}"
    encrypt        = true
    use_lockfile   = true
  }
}
EOF
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  region  = "${local.region}"
  profile = "${local.profile}"
}
EOF
}

inputs = {
  cluster_name = "nsha-study"
}