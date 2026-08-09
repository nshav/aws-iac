locals {
  region  = get_env("AWS_DEFAULT_REGION", "us-east-1")
  profile = get_env("AWS_PROFILE", "terraform-private-aws")
}

generate "backend" {
  path      = "backend.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
terraform {
  backend "s3" {
    bucket         = "nshavandin-eks-state"
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
terraform {
  required_version = ">= 1.14.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region  = "${local.region}"
  profile = "${local.profile}"
}
EOF
}

inputs = {
  cluster_name = get_env("CLUSTER_NAME")
  environment = "study"
}