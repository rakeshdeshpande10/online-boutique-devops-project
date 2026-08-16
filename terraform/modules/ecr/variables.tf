variable "service_name" {
  description = "The name of the service for which the ECR repository is being created."
  type        = list(string)
  default     = ["frontend", "checkoutservice", "recommendationservice", "currencyservice", "adservice"]
}