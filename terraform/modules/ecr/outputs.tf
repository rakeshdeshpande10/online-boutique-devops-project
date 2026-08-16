output "ecr_repository_urls" {
  value = { for service, repo in aws_ecr_repository.ecr_repository : service => repo.repository_url }
}