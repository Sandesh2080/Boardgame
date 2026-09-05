# 1. Define the AWS Provider
provider "aws" {
  region = "us-east-1" # Change to your target region
}

# 2. Create the ECR Repository
resource "aws_ecr_repository" "app_repo" {
  name                 = "dev/microsvc"
  image_tag_mutability = "MUTABLE" 

  # Automatically scan images for vulnerabilities when pushed
  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Environment = "Dev"
    ManagedBy   = "Terraform"
  }
}

# 3. Add a Lifecycle Policy
resource "aws_ecr_lifecycle_policy" "app_repo_cleanup" {
  repository = aws_ecr_repository.app_repo.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep only the last 30 images"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 30
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}
