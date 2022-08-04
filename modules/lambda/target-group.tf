## Define ALB TargetGroup for Lambda
resource "aws_alb_target_group" "tg80" {
  name        = "${local.function_name}-tg80"
  vpc_id      = var.vpc_id
  protocol    = "HTTP"
  port        = var.lambda_port
  target_type = "lambda"
  tags        = merge(local.tags, {})
}

resource "aws_lb_listener_rule" "alb_rule" {
  listener_arn = data.aws_alb_listener.pub_https.arn
  priority     = 1

  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.tg80.arn
  }

  condition {
    host_header {
      values = [local.hostname]
    }
  }

}

resource "aws_route53_record" "this" {
  zone_id         = data.aws_route53_zone.public.zone_id
  name            = local.hostname
  type            = "CNAME"
  ttl             = "300"
  records         = [data.aws_alb.this.dns_name]
  allow_overwrite = true
}
