#!/usr/bin/env bash
set -euo pipefail

# Starts a community localstack container and applies the localstack terraform root against it.

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENDPOINT="http://localhost:4566"
IMAGE="localstack/localstack:3.8"
NAME="localstack-main"

echo "==> starting localstack ($IMAGE)"
if ! docker ps --format '{{.Names}}' | grep -q "^${NAME}$"; then
  docker rm -f "$NAME" >/dev/null 2>&1 || true
  docker run -d --name "$NAME" -p 4566:4566 \
    -e SERVICES=ec2,elbv2,iam,sts \
    -e EAGER_SERVICE_LOADING=1 \
    -e DISABLE_EC2_IMAGE_VALIDATION=1 \
    "$IMAGE" >/dev/null
fi

echo "==> waiting for localstack to become healthy"
for _ in $(seq 1 30); do
  if curl -fsS "${ENDPOINT}/_localstack/health" 2>/dev/null | grep -q '"ec2": "available"'; then
    break
  fi
  sleep 2
done

echo "==> terraform apply against localstack"
cd "${ROOT}/terraform/localstack"
terraform init -input=false
terraform apply -auto-approve -input=false
terraform output

echo "==> resources created in localstack"
AWS_ACCESS_KEY_ID=test AWS_SECRET_ACCESS_KEY=test AWS_DEFAULT_REGION=eu-west-2 \
  aws --endpoint-url="$ENDPOINT" ec2 describe-instances \
  --query 'Reservations[].Instances[].{id:InstanceId,state:State.Name,type:InstanceType}' --output table

echo "==> done. Tear down with: cd terraform/localstack && terraform destroy -auto-approve && docker rm -f ${NAME}"
