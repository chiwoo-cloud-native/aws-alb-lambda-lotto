data "aws_region" "current" {}

data "aws_route53_zone" "public" {
  name = var.domain
}

data "aws_acm_certificate" "this" {
  domain = var.domain
}

/*data "aws_vpc" "this" {
  filter {
    name   = "tag:Name"
    values = [format("%s-vpc", local.name_prefix)]
  }
}*/

data "aws_subnets" "apps" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
  filter {
    name   = "tag:Name"
    values = [format("%s-apps*", local.name_prefix)]
  }
}

# ALB
data "aws_alb" "this" {
  arn = var.alb_arn
  # name = format("%s-pub-alb", local.name_prefix)
}

data "aws_alb_listener" "pub_https" {
  load_balancer_arn = data.aws_alb.this.arn
  port              = 443
}
