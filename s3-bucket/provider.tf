terraform {
  required_version = ">= 1.14.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.50"
    }
  }
}

provider "aws" {
  profile = var.profile
  region  = var.aws_region

  default_tags {
    tags = {
      ManagedBy = "Terraform"
      Project   = var.cluster_name
    }
  }
}