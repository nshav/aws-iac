variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "service_account_role_arn" {
  description = "IAM role ARN CSI driver service account"
  type        = string
}

variable "addon_version" {
  description = "EBS CSI addon version"
  type        = string
  default     = null
}
