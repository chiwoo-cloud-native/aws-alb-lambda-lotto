variable "context" {
  type = object({
    aws_profile = string # describe a specifc profile to access a aws cli
    region      = string # describe default region to create a resource from aws
    project     = string # project name is usally account's project name or platform name
    environment = string # Runtime Environment such as develop, stage, production
    owner       = string # project owner
    team        = string # Team name of Devops Transformation
    cost_center = number # Cost Center
    domain      = string # public toolchain domain name (ex, tools.customer.co.kr)
    pri_domain  = string # private domain name (ex, tools.customer.co.kr)
  })
}
