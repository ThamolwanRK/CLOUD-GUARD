locals {
  name_prefix = "${var.project_name}-${var.environment}"

  required_tags = {
    Project     = "CloudGuard"
    Environment = var.environment
    Owner       = var.owner
    ManagedBy   = "Terraform"
  }
}
