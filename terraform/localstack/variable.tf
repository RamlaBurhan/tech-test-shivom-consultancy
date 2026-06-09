variable "region" {
  type        = string
  description = "Region passed to the localstack provider"
  default     = "eu-west-2"
}

variable "name" {
  type        = string
  description = "Name prefix for all resources"
  default     = "sample-web-app"
}

variable "localstack_endpoint" {
  type        = string
  description = "Localstack edge endpoint"
  default     = "http://localhost:4566"
}

variable "ami_id" {
  type        = string
  description = "AMI id, any value is accepted by localstack"
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

variable "azs" {
  type        = list(string)
  description = "Availability zones"
  default     = ["eu-west-2a", "eu-west-2b"]
}
