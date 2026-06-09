variable "name" {
  type        = string
  description = "Name prefix for network resources"
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
  description = "Availability zones to spread subnets across"
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to all resources"
  default     = {}
}
