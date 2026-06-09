## Tech Test Shivom Consultancy

A small Node.js web app with everything around it to run in production: CI/CD, infrastructure as code, configuration management, monitoring and centralised logging. The same code runs locally and deploys to AWS.

## What it does

The app serves a landing page and a few JSON endpoints. It exposes Prometheus metrics at `/metrics`, a health check at `/healthz` and structured JSON logs to stdout.

Infrastructue Highlights:

- **CI** (GitHub Actions) builds and tests the app and validates the Terraform and Ansible, on every push and pull request.
- **CD** (GitHub Actions) builds and publishes the container image, then provisions AWS with Terraform and deploys with Ansible.
- **Terraform** provisions the VPC, instances and load balancer using reusable module
- **Ansible** installs Docker on the instances and runs the app container.
- **Monitoring**: Prometheus, Alertmanager, node-exporter and Grafana, with alerts for error rate, latency, CPU, memory and disk.
- **Logging**: Elasticsearch, Logstash and Kibana, with Filebeat shipping the app logs.

## How it works

A commit triggers CI. On `main`, CD builds the image and pushes it to the registry, Terraform provisions the infrastructure, then Ansible configures the instances and pulls the image to run it. Prometheus scrapes the app and the host for Grafana to visualise, while Filebeat ships the logs into Elasticsearch for searching in Kibana.

Everything has a local equivalent so it can be exercised end to end without an AWS account: LocalStack stands in for the AWS API and multipass gives a real VM for Ansible to configure.

## Requirements

Docker, Node.js 20+, Terraform 1.5+, Ansible, multipass and LocalStack. AWS access is only needed for a real cloud deploy. `make help` lists every task.

## Run it locally

The app:

```bash
make install
make lint
make test
make docker-build
```

Monitoring (app on :3000, Prometheus on :9090, Grafana on :3001 with admin/admin):

```bash
make monitoring-up
make monitoring-down
```

Logging (Kibana on :5601):

```bash
make logging-up
make logging-down
```

Infrastructure against LocalStack, applied for real with no AWS account or cost:

```bash
make tf-localstack
```

The Ansible roles on a real VM, provisioned and configured end to end:

```bash
make vm
```

## Run it on AWS

```bash
cd terraform/aws
cp terraform.tfvars.example terraform.tfvars   # edit as needed
terraform init
terraform plan
terraform apply
```

Then deploy the app to the new instances:

```bash
cd ../../ansible
ansible-galaxy collection install -r requirements.yml
ansible-playbook -i inventory/aws_ec2.yml playbook.yml \
  -e app_build_locally=false -e app_image=<your-image>
```

To run the same path from CD, set the `DEPLOY_ENABLED` repository variable to `true` and provide the `AWS_ROLE_ARN`, `AWS_REGION` and `SSH_PRIVATE_KEY` secrets. Aswell as a `ALERTMANAGER_SLACK_WEBHOOK` and `GRAFANA_PASSWORD`.

## Future Improvements

- Auto Scaling — add a target-tracking policy on CPU and request count
- HTTPS — ACM certificate with ALB listener rule
- Container registry — move image storage to a private ECR
- Testing — add Molecule to test each Ansible role in isolation fast local feedback before roles are applied to a real VM