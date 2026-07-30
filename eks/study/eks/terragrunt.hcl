include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../modules/eks"
}

dependency "vpc" {
    config_path = "../vpc"
    mock_outputs = {
      vpc_id             = "vpc-mock"
      private_subnet_ids = ["subnet-mock-1", "subnet-mock-2"]
      public_subnet_ids  = ["subnet-mock-3", "subnet-mock-4"]
    }
    mock_outputs_allowed_terraform_commands = ["plan", "validate"]
  }

dependency "iam" {
    config_path = "../iam"
    mock_outputs = {
      cluster_role_arn = "arn:aws:iam::000000000000:role/mock-cluster"
      node_group_arn   = "arn:aws:iam::000000000000:role/mock-node"
    }
    mock_outputs_allowed_terraform_commands = ["plan", "validate"]
  }

inputs = {
  private_subnet_ids = dependency.vpc.outputs.private_subnet_ids
  public_subnet_ids  = dependency.vpc.outputs.public_subnet_ids
  cluster_role_arn   = dependency.iam.outputs.cluster_role_arn
  node_group_arn     = dependency.iam.outputs.node_group_arn
}
