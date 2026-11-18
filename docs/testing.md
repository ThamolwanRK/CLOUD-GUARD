# Testing Strategy

## Static checks

- Terraform formatting
- Terraform initialization without backend configuration
- Terraform validation
- Terraform mock-provider plan assertions without AWS credentials
- OPA syntax and unit tests
- Docker Compose configuration validation
- JSON parsing for dashboards, fixtures, and policy data

## Policy scenarios

The fixture suite includes:

- A compliant plan that passes.
- A warning-only plan that passes with GOV003.
- An insecure plan containing public SSH, unencrypted storage, optional IMDSv1, missing tags, an unapproved region, and an oversized instance.

The evaluator must return exit code 0 for a passing plan, 2 for a blocked plan, and 1 for evaluation errors.

## Pipeline behavior

- A blocking result stops before manual approval.
- Warnings remain visible but do not block.
- Deployment stays disabled unless `DEPLOY_TO_AWS` is selected.
- Deployment still requires an interactive Jenkins approval.
- The saved plan evaluated by OPA is the same plan supplied to `terraform apply`.

## Deployment validation

After separately approved deployment:

- The website returns HTTP 200.
- The EC2 root volume is encrypted.
- IMDSv2 is required.
- No unrestricted SSH rule exists.
- Node Exporter is reachable only from the approved monitoring CIDR.
- Prometheus reports the target as up.
- Grafana renders CPU, memory, disk, network, and availability data.

## Evaluation measures

Record true positives, expected passes, false positives, policy execution time, and total pipeline time. Limit conclusions to the tested policies and scenarios.
