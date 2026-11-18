# CloudGuard

CloudGuard is a policy-driven DevSecOps prototype that evaluates Terraform plans for security, governance, and cost risks before AWS deployment. Jenkins runs the pipeline, Open Policy Agent (OPA) makes the policy decision, and Prometheus with Grafana provides post-deployment observability.

The deployed workload is intentionally small: one Amazon Linux EC2 instance in a public subnet serving a static demonstration page. The web page proves that an approved plan can become a working deployment; it is not the CloudGuard control plane.

## Delivery workflow

```text
GitHub
  -> Jenkins checkout
  -> terraform fmt and validate
  -> terraform plan
  -> terraform show -json
  -> OPA policy evaluation
       -> FAIL: block and publish violations
       -> PASS: require manual approval
  -> terraform apply
  -> EC2 demonstration website
  -> Prometheus metrics
  -> Grafana dashboard
```

Cloud deployment is disabled by default. The pipeline creates plans and evaluates policy without applying them unless an operator explicitly enables and approves the deployment stage.

## Repository layout

| Path | Purpose |
|---|---|
| `terraform/` | AWS VPC, public subnet, security group, and EC2 workload |
| `policies/` | OPA/Rego security, governance, and cost policies |
| `tests/fixtures/` | Compliant and non-compliant Terraform-plan fixtures |
| `scripts/` | Policy evaluation and report generation |
| `jenkins/` | Reproducible Jenkins controller image |
| `monitoring/` | Prometheus and Grafana configuration |
| `docs/` | Architecture, policies, setup, testing, and progress records |

## Safe local checks

These checks do not create AWS resources:

```powershell
terraform -chdir=terraform fmt -check -recursive
terraform -chdir=terraform init -backend=false
terraform -chdir=terraform validate
docker compose run --rm policy-test
```

Terraform planning requires AWS authentication because the configuration resolves an Amazon Linux AMI. Follow `docs/aws-identity-setup.md` yourself; never provide credentials to another person or commit them to Git.

## Local services

```powershell
docker compose up -d --build jenkins prometheus grafana
```

- Jenkins: <http://localhost:8080>
- Prometheus: <http://localhost:9090>
- Grafana: <http://localhost:3000>

Grafana's initial local administrator password is supplied through an untracked `.env` file. Copy `.env.example` to `.env` and set a unique value before starting the stack.

## Safety boundaries

- Never commit `.tfstate`, plan files, credentials, private keys, `.env`, or Jenkins secrets.
- Never use AWS root credentials with Terraform or Jenkins.
- `terraform apply` and `terraform destroy` remain manual, separately approved operations.
- Intentionally unsafe examples are plan fixtures and must not be deployed.
- The default infrastructure uses no NAT Gateway, load balancer, database, or second EC2 instance.

See [the architecture guide](docs/architecture.md) and [local setup guide](docs/local-setup.md) for the full design.
