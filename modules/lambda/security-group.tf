locals {
  sg_name = format("%s-sg", local.function_name)
}

resource "aws_security_group" "this" {
  name        = local.sg_name
  description = "Allow inbound traffic from ALB"
  vpc_id      = var.vpc_id

  tags = merge(local.tags, {
    Name = local.sg_name
  })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "ingress_rule" {
  security_group_id        = aws_security_group.this.id
  description              = "Allows lambda to establish connections from ALB"
  type                     = "ingress"
  from_port                = var.lambda_port
  to_port                  = var.lambda_port
  protocol                 = "TCP"
  source_security_group_id = var.source_security_group_id
}

resource "aws_security_group_rule" "egress_rule" {
  security_group_id = aws_security_group.this.id
  description       = "Allows lambda to establish connections to all resources"
  type              = "egress"
  from_port         = "0"
  to_port           = "0"
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}
