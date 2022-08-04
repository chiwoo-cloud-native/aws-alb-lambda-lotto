variable "aws_profile" { type = string }
variable "aws_region" { type = string }
variable "vpc_id" { type = string }
variable "alb_arn" { type = string }
variable "source_security_group_id" { type = string }
variable "name_prefix" { type = string }
variable "domain" { type = string }
variable "tags" { type = map(string) }
variable "function_name" { type = string }
variable "hostname" { type = string }

variable "https_port" {
  type    = string
  default = "443"
}

variable "lambda_port" {
  type    = number
  default = 80
}
