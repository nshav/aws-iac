# Include root configurations if applicable
include "root" {
  path = find_in_parent_folders("root.hcl")
}

# Use the official AWS IAM EKS Module
terraform {
  source = "tfr:///terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks?version=5.44.0"
}

dependency "eks" {
  config_path = "../eks"
  mock_outputs = {
    oidc_provider_arn = "arn:aws:iam::000000000000:oidc-provider/mock"
  }
}

inputs = {
  role_name_prefix = "eks-ebs-csi-driver-"
  
  attach_ebs_csi_policy = true 

  oidc_providers = {
    main = {
      provider_arn               = dependency.eks.outputs.oidc_provider_arn
      namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
    }
  }

  tags = {
    Environment = "production"
    Automation  = "Terragrunt"
  }
}
