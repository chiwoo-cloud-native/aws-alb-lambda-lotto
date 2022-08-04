resource "aws_ecr_repository" "this" {
  name         = format("%s-ecr", local.function_name)
  force_delete = true
  tags         = merge(local.tags, {})
}

resource "aws_ecr_lifecycle_policy" "this" {
  repository = aws_ecr_repository.this.name
  policy     = <<EOF
{
    "rules": [
        {
            "rulePriority": 1,
            "description": "Keep last 2 images",
            "selection": {
                "tagStatus": "any",
                "countType": "imageCountMoreThan",
                "countNumber": 2
            },
            "action": {
                "type": "expire"
            }
        }
    ]
}
EOF
}

locals {
  current_region = data.aws_region.current.id
  repository_url = aws_ecr_repository.this.repository_url
}

resource "null_resource" "push_to_ecr" {

  provisioner "local-exec" {
    command = <<EOF
docker build -t "${local.repository_url}:latest" -f ./nodejs/Dockerfile .
EOF
  }

  provisioner "local-exec" {
    command = <<EOF
aws ecr get-login-password --region ${local.current_region} | docker login --username AWS --password-stdin ${local.repository_url}
docker push ${local.repository_url}:latest
    EOF

    environment = {
      AWS_PROFILE = var.aws_profile
      AWS_REGION  = var.aws_region
    }
  }

  depends_on = [
    aws_ecr_repository.this
  ]

}
