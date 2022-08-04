output "function_name" {
  value = aws_lambda_function.this.function_name
}

output "lambda_role_name" {
  value = aws_iam_role.this.name
}

output "lambda_policy_name" {
  value = aws_iam_policy.this.name
}

output "domain_name" {
  value = local.hostname
}

output "ecr_repository_url" {
  value = aws_ecr_repository.this.repository_url
}


output "alb_subnets" {
  value = data.aws_alb.this.subnets
}
