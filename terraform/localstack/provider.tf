provider "aws" {
  region                      = var.region
  access_key                  = "test"
  secret_key                  = "test"
  s3_use_path_style           = true
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  default_tags {
    tags = {
      Project   = var.name
      ManagedBy = "terraform"
    }
  }

  endpoints {
    ec2   = var.localstack_endpoint
    elbv2 = var.localstack_endpoint
    iam   = var.localstack_endpoint
    sts   = var.localstack_endpoint
  }
}
