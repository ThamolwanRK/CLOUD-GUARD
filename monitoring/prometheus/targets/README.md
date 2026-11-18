# Prometheus targets

After an approved deployment, create the ignored file `ec2.json` in this directory:

```json
[
  {
    "targets": ["203.0.113.10:9100"],
    "labels": {
      "environment": "dev",
      "project": "CloudGuard"
    }
  }
]
```

Replace the example address with the `node_exporter_target` Terraform output. The EC2 security group must restrict port 9100 to the workstation running Prometheus.
