variable "region" {
  type        = string
  description = "AWS region to deploy into"
  default     = "eu-west-2"
}

variable "name" {
  type        = string
  description = "Name prefix for all resources"
  default     = "sample-web-app"
}

variable "environment" {
  type        = string
  description = "Environment name"
  default     = "dev"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the VPC"
  default     = "10.20.0.0/16"
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "CIDR blocks for the public subnets"
  default     = ["10.20.1.0/24", "10.20.2.0/24"]
}


variable "azs" {
  type        = list(string)
  description = "Availability zones, must match the region"
  default     = ["eu-west-2a", "eu-west-2b"]
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type for the application"
  default     = "t3.large"
}

variable "instance_count" {
  type        = number
  description = "Number of application instances"
  default     = 2
}

variable "key_name" {
  type        = string
  description = "Existing EC2 key pair name for SSH, empty to disable"
  default     = "ansible-ec2-platform"
}

variable "allowed_ssh_cidr" {
  type        = string
  description = "CIDR allowed to reach SSH"
  default     = "0.0.0.0/0"
}

variable "enable_alb" {
  type        = bool
  description = "Whether to create a load balancer in front of the instances"
  default     = true
}
