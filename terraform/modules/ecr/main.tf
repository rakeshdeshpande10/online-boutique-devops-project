resource "aws_ecr_repository" "ecr_repository" {
    for_each = toset(var.service_name)
    name     = each.value
    image_tag_mutability = "IMMUTABLE"
    force_delete = true

    image_scanning_configuration {
        scan_on_push = true
    }
}