variable "ecr_repository_names" {
  description = "List of ECR repository names this role is allowed to push/pull"
  type        = list(string)
}

variable "region" {
  description = "AWS region"
  type        = string
}