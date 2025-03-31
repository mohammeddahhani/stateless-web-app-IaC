locals {
  # pick the a public subnet for the NAT Gateway
  nat_gw_pub_subnet   = keys(var.subnets["public"])[0]

  # pick a private address for the NAT Gateway (fifth to last when possible)
  mask_               = tonumber(element(split("/", var.vpc_cidr), 1))
  total_              = pow(2,  (32 - local.mask_)) - 5  
  nat_gw_private_ip   = cidrhost(var.vpc_cidr, local.total_ > 0 ? local.total_ : 1)
}