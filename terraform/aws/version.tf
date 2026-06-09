terraform {
  required_version = ">= 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # If you want to use the aws/ directory with LocalStack, comment out the S3 backend:
  backend "s3" {
    bucket       = "terraform-state-tech-test-shivom"
    key          = "terraform/aws/terraform.tfstate"
    region       = "eu-west-2"
    use_lockfile = true
    encrypt      = true
  }
}