variable "cluster_subnet_ids" {
  description = "List of subnet IDs for the EKS cluster."
  type        = list(string)
}

variable "node_subnet_ids" {
  description = "List of subnet IDs for the EKS node group."
  type        = list(string)
}

variable "node_instance_types" {
  description = "EC2 instance type for the EKS node group."
  type        = list(string)
  default     = ["t3.medium"]
}

variable "cluster_name" {
  description = "Name of EKS cluster"
  type = string
  default = "online-boutique-eks"
}