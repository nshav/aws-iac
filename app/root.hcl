locals {
  region  = get_env("AWS_DEFAULT_REGION", "us-east-1")
  profile = get_env("AWS_PROFILE", "terraform-private-aws")
  cluster_name = get_env("CLUSTER_NAME")
}

generate "backend" {
  path      = "backend.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
terraform {
  backend "s3" {
    bucket         = "nshavandin-app-state"
    key            = "${path_relative_to_include()}/tofu.tfstate"
    region         = "${local.region}"
    profile = "${local.profile}"
    encrypt        = true
    use_lockfile   = true
  }
}
EOF
}

generate "overwrite_data" {
  path      = "data.tf"
  if_exists = "overwrite"
  contents  = <<EOF
data "aws_eks_cluster" "existing" {
    name = "${local.cluster_name}"
}

data "aws_eks_cluster_auth" "existing" {
    name = "${local.cluster_name}"
}
EOF
}


generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
terraform {
    required_providers {
      aws = {
        source  = "hashicorp/aws"
        version = "~> 6.50"
      }
      helm = {
        source  = "hashicorp/helm"
        version = "~> 3.0"
      }
      kubernetes = {
        source  = "hashicorp/kubernetes"
        version = "~> 2.30"
      }
    }
  }

provider "aws" {
  region  = "${local.region}"
  profile = "${local.profile}"
}

provider "kubernetes" {
    host                   = data.aws_eks_cluster.existing.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.existing.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.existing.token
}

provider "helm" {
  kubernetes = {
    host                   = data.aws_eks_cluster.existing.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.existing.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.existing.token
  }
}
EOF
}

inputs = {
  httpbin_hostname = get_env("HTTPBIN_HOSTNAME")
} 
