variable "name" {
  type        = string
  description = "Name prefix for compute resources"
}

variable "vpc_id" {
  type        = string
  description = "VPC to launch resources into"
}

variable "subnet_ids" {
  type        = list(string)
  description = "Subnets for instances and the load balancer"
}

variable "ami_id" {
  type        = string
  description = "AMI id for the application instances"
  default     = "ami-0123456789abcdef0"
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type"
  default     = "t3.micro"
}

variable "instance_count" {
  type        = number
  description = "Number of application instances"
  default     = 1
}

variable "app_port" {
  type        = number
  description = "Port the application listens on"
  default     = 3000
}

variable "key_name" {
  type        = string
  description = "Existing EC2 key pair name for SSH, empty to disable"
  default     = ""
}

variable "user_data" {
  type        = string
  description = "Cloud-init user data, empty to disable"
  default     = ""
}

variable "associate_public_ip" {
  type        = bool
  description = "Whether to assign a public IP to instances"
  default     = true
}

variable "allowed_ssh_cidr" {
  type        = string
  description = "CIDR allowed to reach SSH"
  default     = "0.0.0.0/0"
}

variable "metrics_cidr" {
  type        = string
  description = "CIDR allowed to scrape node-exporter"
  default     = "0.0.0.0/0"
}

variable "enable_alb" {
  type        = bool
  description = "Whether to create an application load balancer"
  default     = true
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to all resources"
  default     = {}
}
