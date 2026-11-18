# CloudGuard Architecture

## Purpose

CloudGuard prevents selected insecure, ungoverned, or unnecessarily expensive Terraform changes from reaching AWS. The prototype demonstrates prevention before deployment and observability after deployment.

## System flow

```text
Developer -> GitHub -> Jenkins
                        |
                        +-> Terraform format and validation
                        +-> Terraform plan and JSON conversion
                        +-> OPA policy tests and plan evaluation
                              |
                              +-> Blocking violation: stop and report
                              +-> Warning: report and continue
                              +-> Pass: request manual approval
                                         |
                                         v
                                  Terraform apply
                                         |
                                         v
                       VPC -> public subnet -> one EC2 web workload
                                                   |
                                                   v
                                            Node Exporter
                                                   |
                                                   v
                                     Prometheus -> Grafana
```

## User-visible surfaces

CloudGuard does not need a custom application frontend for the prototype:

- The EC2 static website proves successful deployment.
- Jenkins displays pipeline stages and manual approval.
- The generated HTML policy report explains decisions and remediation.
- Grafana displays post-deployment metrics.

## AWS scope

The initial deployment contains one VPC, one public subnet, one Internet Gateway, one route table, one security group, and one EC2 instance. It deliberately excludes private subnets, NAT Gateways, load balancers, databases, and additional instances.

The EC2 instance uses an encrypted root volume, requires IMDSv2, serves HTTP on port 80, and exposes Node Exporter only to the approved workstation CIDR. SSH is disabled by default.

## Trust boundaries

- GitHub stores source but never credentials, state, or plan files.
- Jenkins stores the automation credential in its credential store.
- Terraform proposes infrastructure; it cannot apply unless the operator enables deployment.
- OPA evaluates the immutable saved plan that Terraform would apply.
- The operator must approve the exact saved plan before application.
- Prometheus reaches only the restricted Node Exporter endpoint.

## Cost controls

- At most one approved micro instance is allowed.
- NAT Gateways, load balancers, and managed databases produce warnings.
- Deployment is disabled by default.
- Public IPv4 and EC2/EBS usage can incur charges while running.
- A documented destroy procedure is required after demonstrations.
