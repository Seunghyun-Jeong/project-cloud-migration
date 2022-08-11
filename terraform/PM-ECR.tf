resource "aws_ecr_repository" "ECR" {
  name                 = "project"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }
}
