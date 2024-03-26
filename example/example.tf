provider "aws" {
  region = "us-west-2"
}

locals {
  name        = "app"
  environment = "test"
}

##-----------------------------------------------------------------------------
## A VPC is a virtual network that closely resembles a traditional network that you'd operate in your own data center.
##-----------------------------------------------------------------------------
module "vpc" {
  source      = "git@github.com:slovink/terraform-aws-vpc.git?ref=v1.0.0"
  name        = local.name
  environment = local.environment
  cidr_block  = "172.16.0.0/16"
}

##-----------------------------------------------------
## A subnet is a range of IP addresses in your VPC.
##-----------------------------------------------------
module "public_subnets" {
  source = "git@github.com:slovink/terraform-aws-subnet.git?ref=v1.0.0"

  name               = local.name
  environment        = local.environment
  availability_zones = ["us-west-2a", "us-west-2b"]
  vpc_id             = module.vpc.id
  type               = "public"
  igw_id             = module.vpc.igw_id
  cidr_block         = module.vpc.vpc_cidr_block
  ipv6_cidr_block    = module.vpc.ipv6_cidr_block
}

##-----------------------------------------------------------------------------
## vpn module call.
##-----------------------------------------------------------------------------
module "vpn" {
  source = "./../"

  name                                      = local.name
  environment                               = local.environment
  vpc_id                                    = module.vpc.id
  customer_ip_address                       = "115.160.246.74"
  local_ipv4_network_cidr                   = "0.0.0.0/0"
  remote_ipv4_network_cidr                  = module.vpc.vpc_cidr_block
  vpn_connection_static_routes_destinations = ["10.80.1.0/24"]

}
