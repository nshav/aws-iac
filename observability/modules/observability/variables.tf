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