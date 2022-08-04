output "alb_arn" {
  value = module.alb.lb_arn
}

output "alb_security_group_id" {
  value = aws_security_group.this.id
}
