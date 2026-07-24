resource "aws_eks_cluster" "main" {
  name     = var.cluster_name
  role_arn = aws_iam_role.cluster.arn
  version  = var.cluster_version

  vpc_config {
    subnet_ids = concat(aws_subnet.private[*].id, aws_subnet.public[*].id)
    #subnet_ids              = aws_subnet.public[*].id
    endpoint_private_access = true
    endpoint_public_access  = true
    public_access_cidrs     = ["0.0.0.0/0"]
  }

  # enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  # encryption_config {
  #   provider {
  #     key_arn = aws_kms_key.eks.arn
  #   }
  #   resources = ["secrets"]
  # }

  depends_on = [
    aws_iam_role_policy_attachment.cluster_policy,
    # aws_cloudwatch_log_group.cluster
  ]
}

# resource "aws_kms_key" "eks" {
#   description = "EKS cluster encryption key"
# }

# resource "aws_cloudwatch_log_group" "cluster" {
#   name              = "/aws/eks/${var.cluster_name}/cluster"
#   retention_in_days = 7
# }


resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${var.cluster_name}-main"
  node_role_arn   = aws_iam_role.node_group.arn
  subnet_ids      = aws_subnet.private[*].id
  #subnet_ids      = aws_subnet.public[*].id

  scaling_config {
    desired_size = 2
    max_size     = 4
    min_size     = 1
  }

  update_config {
    max_unavailable_percentage = 33
  }

  instance_types = ["t3.medium"]

  disk_size = 20

  labels = {
    role = "general"
  }

  tags = {
    "k8s.io/cluster-autoscaler/${var.cluster_name}" = "owned"
    "k8s.io/cluster-autoscaler/enabled"             = "true"
  }

  depends_on = [
    aws_iam_role_policy_attachment.node_policies
  ]
}

# resource "aws_eks_node_group" "spot" {
#   cluster_name    = aws_eks_cluster.main.name
#   node_group_name = "${var.cluster_name}-spot"
#   node_role_arn   = aws_iam_role.node_group.arn
#   #subnet_ids      = aws_subnet.private[*].id
#   subnet_ids      = aws_subnet.public[*].id
#   capacity_type   = "SPOT"

#   scaling_config {
#     desired_size = 1
#     max_size     = 3
#     min_size     = 0
#   }

#   instance_types = ["t3.medium", "t3a.medium"]

#   taint {
#     key    = "spot"
#     value  = "true"
#     effect = "NO_SCHEDULE"
#   }
# }


# resource "null_resource" "kubectl_config" {
#   provisioner "local-exec" {
#     command = "aws eks update-kubeconfig --region ${var.aws_region} --name ${var.cluster_name}"
#   }
#   depends_on = [aws_eks_cluster.main]
# }

# resource "aws_eks_addon" "vpc_cni" {
#   cluster_name = aws_eks_cluster.main.name
#   addon_name   = "vpc-cni"
#   addon_version = "v1.15.4-eksbuild.1"
# }

# resource "aws_eks_addon" "ebs_csi_driver" {
#   cluster_name = aws_eks_cluster.main.name
#   addon_name   = "aws-ebs-csi-driver"
#   addon_version = "v1.26.1-eksbuild.1"
# }
