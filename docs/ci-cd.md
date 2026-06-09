Two GitHub Actions workflows live in `.github/workflows`.

## CI (`ci.yml`)

Runs on every push to `main` and every pull request. It has three independent jobs so a failure in one area is easy to locate.

- **app**: installs dependencies with `npm ci`, runs ESLint, runs the Jest unit tests with coverage, then builds the Docker image. Coverage thresholds are enforced in `app/jest.config.js`.
- **terraform**: runs `terraform fmt -check`, then `init -backend=false` and `validate` for both the AWS and LocalStack roots, then `tflint` recursively.
- **ansible**: runs `yamllint` and `ansible-lint` at the production profile.

Concurrency is set so a new push cancels an in-flight run on the same ref.

## CD (`cd.yml`)

Runs on pushes to `main`, on `v*` tags and on manual dispatch.

- **build-and-push**: builds the image from `app/` and pushes it to GitHub Container Registry tagged with the short SHA and `latest`. Build cache is stored in the Actions cache.
- **deploy**: gated behind the `production` environment and the `DEPLOY_ENABLED` repository variable, so it never runs by accident. It assumes an AWS role through OIDC (no long-lived keys), runs `terraform apply` for the AWS root, reads the instance IPs from Terraform outputs, then runs the Ansible playbook against those hosts pulling the freshly published image.

## Required configuration for a live deploy

Repository variables:

- `DEPLOY_ENABLED` set to `true`.
- `AWS_REGION`.

Repository secrets:

- `AWS_ROLE_ARN` for the OIDC role the deploy job assumes.
- `SSH_PRIVATE_KEY` matching the key pair given to the instances.
- `GAFANA_PASSWORD` admin password injected into the Grafana config at deploy time.
- `ALERTMANAGER_SLACK_WEBHOOK`  Slack incoming webhook URL for Alertmanager firing/resolved notifications.

## Local equivalents

Every CI step has a `make` target: `make lint`, `make test`, `make docker-build`, `make tf-validate`, `make ansible-lint`. The deploy path is reproduced locally with `make tf-localstack` and `make vm`.
