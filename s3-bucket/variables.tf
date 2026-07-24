variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.35"
}

variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "profile" {
  type = string
}
