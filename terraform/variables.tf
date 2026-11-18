variable "aws_region" {
  description = "Approved AWS region for the academic prototype."
  type        = string
  default     = "ap-south-1"

  validation {
    condition     = contains(["ap-south-1"], var.aws_region)
    error_message = "CloudGuard currently permits only ap-south-1."
  }
}

variable "project_name" {
  description = "Project identifier used in names and tags."
  type        = string
  default     = "cloudguard"

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{2,23}$", var.project_name))
    error_message = "project_name must be 3-24 lowercase letters, digits, or hyphens and start with a letter."
  }
}

variable "environment" {
  description = "Deployment environment."
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "test"], var.environment)
    error_message = "The academic prototype supports only dev or test."
  }
}

variable "owner" {
  description = "Human-readable owner tag."
  type        = string
  default     = "ThamolwanRK"

  validation {
    condition     = length(trimspace(var.owner)) >= 3
    error_message = "owner must contain at least three characters."
  }
}

variable "vpc_cidr" {
  description = "CIDR block for the prototype VPC."
  type        = string
  default     = "10.20.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for the single public subnet."
  type        = string
  default     = "10.20.10.0/24"
}

variable "instance_type" {
  description = "EC2 instance type. Cost policy restricts development to this allowlist."
  type        = string
  default     = "t3.micro"

  validation {
    condition     = contains(["t3.micro", "t3a.micro"], var.instance_type)
    error_message = "Use an approved micro instance type for the academic prototype."
  }
}

variable "enable_ssh" {
  description = "Whether to allow direct SSH. Disabled by default; EC2 Instance Connect or Session Manager is preferred."
  type        = bool
  default     = false
}

variable "allowed_ssh_cidr" {
  description = "Single trusted IPv4 CIDR allowed to use SSH when enable_ssh is true."
  type        = string
  default     = "127.0.0.1/32"

  validation {
    condition     = !contains(["0.0.0.0/0", "::/0"], var.allowed_ssh_cidr)
    error_message = "SSH must never be open to the internet."
  }
}

variable "monitoring_cidr" {
  description = "Trusted IPv4 CIDR allowed to scrape Node Exporter. Replace with your current public IP/32 before deployment."
  type        = string
  default     = "127.0.0.1/32"

  validation {
    condition     = !contains(["0.0.0.0/0", "::/0"], var.monitoring_cidr)
    error_message = "Node Exporter must not be exposed to the internet."
  }
}
