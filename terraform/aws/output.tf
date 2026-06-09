output "vpc_id" {
  value       = module.network.vpc_id
  description = "ID of the VPC"
}

output "instance_public_ips" {
  value       = module.compute.instance_public_ips
  description = "Public IPs of the application instances"
}

output "alb_dns_name" {
  value       = module.compute.alb_dns_name
  description = "DNS name of the load balancer"
}
