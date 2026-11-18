# CloudGuard Policy Catalog

| ID | Category | Severity | Mode | Condition |
|---|---|---:|---|---|
| SEC001 | Security | Critical | Blocking | A sensitive port is open to `0.0.0.0/0` or `::/0` |
| SEC002 | Security | High | Blocking | EC2 root storage encryption is absent or disabled |
| SEC003 | Security | High | Blocking | EC2 does not require IMDSv2 |
| GOV001 | Governance | High | Blocking | A taggable resource lacks Project, Environment, Owner, or ManagedBy |
| GOV002 | Governance | High | Blocking | AWS region is outside the approved list |
| GOV003 | Governance | Medium | Warning | A resource Name tag violates the naming convention |
| COST001 | Cost | High | Blocking | A development EC2 type is outside the micro allowlist |
| COST002 | Cost | High | Blocking | The plan proposes more than one EC2 instance |
| COST003 | Cost | Medium | Warning | The plan includes a NAT Gateway, load balancer, or managed database |

Each violation includes its policy ID, category, severity, enforcement mode, resource address, message, and remediation. Rego unit tests cover every policy family.

Cost checks are guardrails, not monetary estimates. Current prices are not embedded or presented as verified savings.
