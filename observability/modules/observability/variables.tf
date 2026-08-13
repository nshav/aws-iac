variable "namespace" {
  description = "Namespace name"
  type        = string
  default = "monitoring"
}

variable "kps_name" {
  description = "kube-prometheus-stack name"
  type        = string
  default     = "prometheus-stack"
}

variable "loki_name" {
  description = "Loki name"
  type        = string
  default     = "loki"
}

variable "alloy_name" {
  description = "Alloy name"
  type        = string
  default     = "alloy"
}

variable "cluster_name" {
  description = "Cluster name"
  type        = string
}

variable "aws_region" {
  description = "AWS regions"
  type        = string
}

variable "grafana_admin_password" {
  description = "Grafana admin password"
  type        = string
  sensitive   = true
}

variable "grafana_hostname" {
  description = "Grafana hostname"
  type        = string
}