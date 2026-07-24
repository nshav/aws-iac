terraform {
  backend "s3" {
    bucket       = "nshavandin-eks-tfstate"
    key          = "eks/terraform.tfstate"
    region       = "us-east-1"
    profile      = "terraform-private-aws"
    encrypt      = true
    use_lockfile = true
  }
}