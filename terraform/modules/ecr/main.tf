resource "aws_ecr_repository" "ecr_repository" {
    for_each = toset(var.service_name)
    name     = each.value
}