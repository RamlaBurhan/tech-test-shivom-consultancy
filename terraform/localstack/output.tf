output "vpc_id" {
  value       = module.network.vpc_id
  description = "ID of the VPC created in localstack"
}

output "public_subnet_ids" {
  value       = module.network.public_subnet_ids
  description = "Public subnet ids"
}

output "instance_ids" {
  value       = module.compute.instance_ids
  description = "Application instance ids"
}

output "instance_private_ips" {
  value       = module.compute.instance_private_ips
  description = "Application instance private IPs"
}
