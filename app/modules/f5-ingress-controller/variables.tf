variable "wallarm_ic_version" {
  description = "Wallarm ingress controller version"
  type        = string
  default     = "6.13.0"
}

variable "wallarm_ic_name" {
  description = "Wallarm f5 ingress controller name"
  type        = string
  default     = "wallarm-f5-ic"
}

variable "wallarm_api_host" {
  description = "Wallarm api host"
  type        = string
}

variable "wallarm_api_token" {
  description = "Wallarm api token"
  type        = string
  sensitive   = true
}