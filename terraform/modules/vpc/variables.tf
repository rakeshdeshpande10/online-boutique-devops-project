variable "region" {
  description = "The AWS region to create resources in."
  type        = string
  default     = "us-east-1"
  
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "The CIDR block for the public subnet."
  type        = string
  default     = "10.0.1.0/24"
}

variable "public_subnet_cidr_2" {
  description = "The CIDR block for the second public subnet."
  type        = string
  default     = "10.0.2.0/24"
}

variable "private_subnet_cidr" {
  description = "The CIDR block for the private subnet."
  type        = string
  default     = "10.0.3.0/24"
}

variable "private_subnet_cidr_2" {
  description = "The CIDR block for the second private subnet."
  type        = string
  default     = "10.0.4.0/24"
}

variable "availability_zone1" {
    description = "Availabilty zone"
    type = string
    default = "us-east-1a"
}

variable "availability_zone2" {
    description = "Availabilty zone"
    type = string
    default = "us-east-1b"
}

variable "cluster_name" {
  description = "Name of EKS cluster"
  type = string
  default = "online-boutique-eks"
}