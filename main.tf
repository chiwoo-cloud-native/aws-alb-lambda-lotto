locals {
  name_prefix = module.ctx.name_prefix
  domain      = module.ctx.domain
  vpc_name    = "${local.name_prefix}-vpc"
  tags        = module.ctx.tags
}

# 네이밍 및 Tagging 속성을 구성
module "ctx" {
  source  = "./modules/context/"
  context = var.context
}

# VPC 리소스 생성
module "vpc" {
  source = "registry.terraform.io/terraform-aws-modules/vpc/aws"
  name   = local.name_prefix
  cidr   = "172.78.0.0/16"

  azs                  = ["apne2-az1", "apne2-az3"]
  public_subnets       = ["172.78.11.0/24", "172.78.12.0/24"]
  public_subnet_suffix = "pub"

  private_subnets       = ["172.78.21.0/24", "172.78.22.0/24"]
  private_subnet_suffix = "apps"

  enable_dns_hostnames = true
  enable_nat_gateway   = false

  tags = merge(local.tags, {})

  vpc_tags = { Name = local.vpc_name }
  igw_tags = { Name = format("%s-igw", local.name_prefix) }
}

# ALB 서비스 구성
module "alb" {
  source      = "./modules/alb/"
  domain      = local.domain
  name_prefix = local.name_prefix
  tags        = local.tags
  vpc_id      = module.vpc.vpc_id
  depends_on = [module.vpc]
}

# Lambda 서비스 구성
module "lambda" {
  source = "./modules/lambda/"
  aws_profile              = module.ctx.context.aws_profile
  aws_region               = module.ctx.region
  domain                   = local.domain
  name_prefix              = local.name_prefix
  tags                     = local.tags
  vpc_id                   = module.vpc.vpc_id
  alb_arn                  = module.alb.alb_arn
  source_security_group_id = module.alb.alb_security_group_id
  function_name            = "lotto"
  hostname                 = "lotto"

  depends_on = [module.alb]
}
