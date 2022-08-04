locals {
  name_prefix = var.name_prefix
  alb_name    = format("%s-pub-alb", local.name_prefix)
  tags        = var.tags
}

module "alb" {
  source = "registry.terraform.io/terraform-aws-modules/alb/aws"

  name               = local.alb_name
  load_balancer_type = "application"
  vpc_id             = var.vpc_id
  security_groups    = [aws_security_group.this.id]
  subnets            = data.aws_subnets.pub.ids

  http_tcp_listeners = [
    {
      port        = 80
      protocol    = "HTTP"
      action_type = "redirect"
      redirect    = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
  ]

  https_listeners = [
    # HTTPS Listener Index = 0 for HTTPS 443
    {
      port            = 443
      protocol        = "HTTPS"
      certificate_arn = data.aws_acm_certificate.this.arn
      action_type     = "fixed-response"
      fixed_response  = {
        content_type = "text/plain"
        message_body = "Fixed Static message - for Root Context"
        status_code  = "200"
      }
    },
  ]

  tags = merge(local.tags, {
    Name = local.alb_name
  })

}
