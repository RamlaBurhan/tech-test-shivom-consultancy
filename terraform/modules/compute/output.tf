output "instance_ids" {
  value       = aws_instance.app[*].id
  description = "IDs of the application instances"
}

output "instance_public_ips" {
  value       = aws_instance.app[*].public_ip
  description = "Public IPs of the application instances"
}

output "instance_private_ips" {
  value       = aws_instance.app[*].private_ip
  description = "Private IPs of the application instances"
}

output "app_security_group_id" {
  value       = aws_security_group.app.id
  description = "Security group id attached to the instances"
}

output "alb_dns_name" {
  value       = var.enable_alb ? aws_lb.this[0].dns_name : null
  description = "DNS name of the load balancer"
}
