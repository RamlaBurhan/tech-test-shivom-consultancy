# Infrastructure

Terraform is organised as a set of reusable modules consumed by two roots.

## Modules

- **network**: a VPC, an internet gateway, public subnets across the given availability zones with a public route table. Outputs the VPC id and subnet ids.
- **compute**: a security group for the instances, the EC2 instances themselves, and an optional application load balancer with a target group and listener. The load balancer is toggled with `enable_alb` so the same module serves both a single-instance setup and a load-balanced one. The instance security group only opens the application port to the load balancer when one exists, otherwise to the world.

Each module declares its own `required_providers`, variables with descriptions and defaults, and outputs, so it can be reused outside this repository.

## Roots

- **`terraform/aws`**: the real target. It resolves the latest Ubuntu 24.04 AMI with a data source, wires the two modules together, exposes the load balancer DNS name, and instance IPs. The S3 backend with state locking is included with my bucket details. Default tags are applied to every resource through the provider.
- **`terraform/localstack`**: the same network and compute modules pointed at a LocalStack endpoint. It uses static fake credentials and a literal AMI id, so `terraform apply` runs offline against the mocked AWS API. This proves the modules actually create resources rather than only passing `validate`.

## Testing without AWS

```bash
make tf-validate
make tf-localstack
```

The LocalStack apply creates a VPC, subnets, a security group and an EC2 instance, all verifiable with `aws --endpoint-url=http://localhost:4566 ec2 describe-instances`.

## Deploying to AWS

```bash
cd terraform/aws
cp terraform.tfvars.example terraform.tfvars   # adjust as needed
terraform init
terraform plan
terraform apply
```

The instance count and load balancer are controlled by `instance_count` and `enable_alb`.
