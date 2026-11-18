# AWS Identity Setup

These steps must be performed by the account owner. Never provide root passwords, MFA codes, access keys, or secret keys to another person or paste them into project files.

## Secure the root identity

1. Sign in as the AWS account root user.
2. Confirm that root MFA is enabled.
3. Confirm that the root user has no access keys.
4. Use root only for account-level tasks that require it.

## Create a human administrative identity

Use AWS IAM Identity Center for routine console and CLI administration with MFA and temporary credentials. Follow AWS's current single-account setup guidance and create your own named user. Do not use this identity as the Jenkins workload identity.

## Create the Jenkins workload identity

Before the first real Terraform plan, create a separate automation identity for Jenkins. It must:

- Have no console password.
- Be limited to the services CloudGuard manages: EC2 and VPC resources in `ap-south-1`.
- Avoid IAM administration, billing, organizations, and unrelated services.
- Use project and environment tag conditions where AWS supports them.
- Be reviewed before an access key is created.

For a local academic Jenkins controller, an access key may be necessary because there is no cloud workload role to attach. Create it only after the permissions policy is reviewed. Enter it directly into Jenkins Credentials with ID `aws-cloudguard`; do not store it in `.env`, Terraform variables, Git, screenshots, or documentation.

## Configure your own CLI session

Prefer IAM Identity Center temporary credentials:

```powershell
aws configure sso
aws sso login --profile cloudguard-admin
aws sts get-caller-identity --profile cloudguard-admin
```

You must run and complete these authentication commands yourself. A successful identity check should show the non-root identity.

## Pre-deployment checks

- AWS Budgets or billing alerts are configured by the account owner.
- The selected region is `ap-south-1`.
- No root credentials are present.
- Jenkins contains only the dedicated automation credential.
- The credential permissions have been tested with a plan before any apply.
