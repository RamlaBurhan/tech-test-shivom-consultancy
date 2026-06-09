data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

module "network" {
  source = "../modules/network"

  name                = var.name
  vpc_cidr            = var.vpc_cidr
  public_subnet_cidrs = var.public_subnet_cidrs
  azs                 = var.azs
}

module "compute" {
  source = "../modules/compute"

  name             = var.name
  vpc_id           = module.network.vpc_id
  subnet_ids       = module.network.public_subnet_ids
  ami_id           = data.aws_ami.ubuntu.id
  instance_type    = var.instance_type
  instance_count   = var.instance_count
  key_name         = var.key_name
  allowed_ssh_cidr = var.allowed_ssh_cidr
  metrics_cidr     = var.vpc_cidr
  enable_alb       = var.enable_alb
}
