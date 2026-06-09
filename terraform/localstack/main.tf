module "network" {
  source = "../modules/network"

  name                = var.name
  vpc_cidr            = "10.20.0.0/16"
  public_subnet_cidrs = ["10.20.1.0/24", "10.20.2.0/24"]
  azs                 = var.azs
}

module "compute" {
  source = "../modules/compute"

  name           = var.name
  vpc_id         = module.network.vpc_id
  subnet_ids     = module.network.public_subnet_ids
  ami_id         = var.ami_id
  instance_type  = var.instance_type
  instance_count = var.instance_count
  enable_alb     = false
}
