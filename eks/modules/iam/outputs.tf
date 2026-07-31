output "cluster_role_arn" {
  description = "ARN of the cluster role"
  value       = aws_iam_role.cluster.arn
}

output "node_group_arn" {
  description = "ARN of the node group role"
  value       = aws_iam_role.node_group.arn 
}