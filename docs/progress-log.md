# CloudGuard Progress Log

## 2026 11 18

**Current phase:** Foundation implementation following Phase 0 design.

**Completed:**

- Connected the local repository to GitHub and reconciled the initial README commit.
- Replaced 32-bit Terraform with Terraform 1.17.2 AMD64.
- Installed AWS CLI v2 without configuring credentials.
- Replaced the broken Windows Jenkins approach with a Docker-based Jenkins LTS design.
- Defined the one-instance public-subnet AWS prototype.
- Added security, governance, and cost policies with tests and reports.
- Added Prometheus and Grafana provisioning.

**Decisions:**

- No custom CloudGuard frontend in the initial prototype.
- One public EC2 workload serves a minimal demonstration website.
- No private subnet, NAT Gateway, load balancer, or database.
- AWS identities and credentials are created and entered only by the account owner.
- AWS deployment remains disabled and requires separate manual approval.

**Validation results:**

- Terraform initialization and validation passed with AWS provider 6.73.0.
- Terraform mock-provider plan test passed without AWS credentials.
- Ten OPA unit tests passed.
- Compliant, warning-only, and blocked fixture reports returned the expected exit codes.
- Jenkins LTS image built with checksum-verified Terraform 1.17.2 and OPA 1.22.4.
- Jenkins and Prometheus runtime smoke tests passed.
- Prometheus configuration and Docker Compose configuration passed validation.

**Next task:** Complete user-owned Jenkins, Grafana, GitHub, and AWS identity setup before any authenticated plan or deployment.
