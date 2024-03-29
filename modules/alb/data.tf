data "aws_acm_certificate" "this" {
  domain = var.domain
}

/*
data "aws_vpc" "this" {
  filter {
    name   = "tag:Name"
    values = [format("%s-vpc", local.name_prefix)]
  }
}
*/

data "aws_subnets" "pub" {
  filter {
    name   = "vpc-id"
    values = [ var.vpc_id ]
  }

  filter {
    name   = "tag:Name"
    values = [ format("%s-pub*", local.name_prefix) ]
  }
}
