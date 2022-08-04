resource "aws_iam_role" "this" {
  name = "${local.function_name}-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

data "aws_iam_policy" "AWSLambdaVPCAccessExecutionRole" {
  arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda_vpc" {
  role = aws_iam_role.this.name
  policy_arn = data.aws_iam_policy.AWSLambdaVPCAccessExecutionRole.arn
}

data "aws_iam_policy_document" "this" {
  # RDS
  statement {
    sid     = ""
    actions = [
      "rds-db:connect"
    ]
    resources = [
      "*"
    ]
  }
}

resource "aws_iam_policy" "this" {
  name = "${local.function_name}-policy"
  policy = data.aws_iam_policy_document.this.json
}

resource "aws_iam_role_policy_attachment" "iam_policy" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.this.arn
}


