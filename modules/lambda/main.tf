locals {
  name_prefix   = var.name_prefix
  function_name = "${local.name_prefix}-${var.function_name}"
  hostname      = "${var.hostname}.${var.domain}"
  tags          = var.tags
}

## Define AWS Lambda
resource "aws_lambda_function" "this" {
  function_name = local.function_name
  image_uri     = "${local.repository_url}:latest"
  package_type  = "Image"
  role          = aws_iam_role.this.arn
  timeout       = 120

  vpc_config {
    subnet_ids         = data.aws_subnets.apps.ids
    security_group_ids = [
      aws_security_group.this.id
    ]
  }

  image_config {
    command = []
  }

  environment {
    variables = {
      key1 = "value1"
      key2 = "value2"
    }
  }

  depends_on = [
    aws_security_group.this,
    null_resource.push_to_ecr
  ]

}

## Allow ALB to invoke Lambda
resource "aws_lambda_permission" "this" {
  statement_id  = "AllowExecutionFromALB"
  action        = "lambda:InvokeFunction"
  principal     = "elasticloadbalancing.amazonaws.com"
  function_name = aws_lambda_function.this.function_name
  source_arn    = aws_alb_target_group.tg80.arn
}

## Attach Lambda to TargetGroup
resource "aws_lb_target_group_attachment" "main" {
  target_group_arn = aws_alb_target_group.tg80.arn
  target_id        = aws_lambda_function.this.arn

  depends_on       = [
    aws_lambda_permission.this
  ]
}


