include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
    source  = "tfr:///terraform-aws-modules/eks/aws?version=20.0.0"
}

inputs = {
  cluster_version                       = 1.33
  
  vpc_id                                = dependency.vpc.outputs.vpc_id
  subnet_ids                            = dependency.vpc.outputs.private_subnets
  
  cluster_endpoint_public_access = true
  enable_cluster_creator_admin_permissions = true

  eks_managed_node_groups = {
    main = {
      instance_types = ["t3.medium"]
      min_size       = 1
      max_size       = 3
      desired_size   = 1

      update_config = {
        max_unavailable_percentage = 33
      }
    }
  }
}

dependency "vpc" {
  config_path = "${get_original_terragrunt_dir()}/../vpc"
  mock_outputs = {
    vpc_id = "vpc-00000000"
    private_subnets = [
      "subnet-00000000",
      "subnet-00000001",
      "subnet-00000002",
    ]
  }
}