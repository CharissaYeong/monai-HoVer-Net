module "monai_ecr" {
  source  = "terraform-aws-modules/ecr/aws"
  version = "~> 3.0"

  # Creates a descriptive, consistent repository name matching your environment prefix
  repository_name = "${var.project}-service"

  # Prevents existing tags (like 'latest') from being overwritten, maintaining a reliable audit trail
  repository_image_tag_mutability = "IMMUTABLE"

  # Automatically scans image layers for software vulnerabilities during push events
  repository_image_scan_on_push = true

  # FinOps Rule: Automatically purges old development images so your storage costs don't balloon
  repository_lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep only the last 10 untagged or development container iterations"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 10
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}
