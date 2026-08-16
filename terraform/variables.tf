variable "region" {
  description = "The AWS region to create resources in."
  type        = string
  default     = "us-east-1"
  
}

variable "cluster_name" {
  description = "Name of EKS cluster"
  type = string
  default = "online-boutique-eks"
}