include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../modules/ebs-csi-addon"
}

dependency "eks" {
  config_path = "../eks"
  mock_outputs = {
    cluster_name = "mock-cluster"
  }
}

dependency "iam" {
  config_path = "../iam"
  mock_outputs = {
    iam_role_arn = "arn:aws:iam::000000000000:role/mock-ebs-csi"
  }
}

inputs = {
  cluster_name             = dependency.eks.outputs.cluster_name
  service_account_role_arn = dependency.iam.outputs.iam_role_arn
}
