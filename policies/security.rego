package cloudguard

import rego.v1

violations contains violation if {
  some resource in active_resources
  resource.type == "aws_vpc_security_group_ingress_rule"
  values := after(resource)
  some cidr in {object.get(values, "cidr_ipv4", ""), object.get(values, "cidr_ipv6", "")}
  public_cidr(cidr)
  some port in data.sensitive_ports
  port_exposed(values, port)
  violation := {
    "policy_id": "SEC001",
    "category": "security",
    "severity": "critical",
    "enforcement": "blocking",
    "resource": resource.address,
    "message": sprintf("Sensitive port %d must not be open to the internet.", [port]),
    "remediation": "Restrict the rule to one approved CIDR or remove it."
  }
}

violations contains violation if {
  some resource in active_resources
  resource.type == "aws_security_group"
  some rule in object.get(after(resource), "ingress", [])
  some cidr in array.concat(object.get(rule, "cidr_blocks", []), object.get(rule, "ipv6_cidr_blocks", []))
  public_cidr(cidr)
  some port in data.sensitive_ports
  port_exposed(rule, port)
  violation := {
    "policy_id": "SEC001",
    "category": "security",
    "severity": "critical",
    "enforcement": "blocking",
    "resource": resource.address,
    "message": sprintf("Sensitive port %d must not be open to the internet.", [port]),
    "remediation": "Restrict the rule to one approved CIDR or remove it."
  }
}

violations contains violation if {
  some resource in active_resources
  resource.type == "aws_instance"
  blocks := object.get(after(resource), "root_block_device", [])
  count(blocks) == 0
  violation := {
    "policy_id": "SEC002",
    "category": "security",
    "severity": "high",
    "enforcement": "blocking",
    "resource": resource.address,
    "message": "EC2 root storage encryption is not explicitly configured.",
    "remediation": "Add root_block_device with encrypted = true."
  }
}

violations contains violation if {
  some resource in active_resources
  resource.type == "aws_instance"
  some block in object.get(after(resource), "root_block_device", [])
  object.get(block, "encrypted", false) != true
  violation := {
    "policy_id": "SEC002",
    "category": "security",
    "severity": "high",
    "enforcement": "blocking",
    "resource": resource.address,
    "message": "EC2 root storage must be encrypted.",
    "remediation": "Set root_block_device.encrypted to true."
  }
}

violations contains violation if {
  some resource in active_resources
  resource.type == "aws_instance"
  metadata := object.get(after(resource), "metadata_options", [])
  count(metadata) == 0
  violation := {
    "policy_id": "SEC003",
    "category": "security",
    "severity": "high",
    "enforcement": "blocking",
    "resource": resource.address,
    "message": "EC2 Instance Metadata Service v2 is not explicitly required.",
    "remediation": "Set metadata_options.http_tokens to required."
  }
}

violations contains violation if {
  some resource in active_resources
  resource.type == "aws_instance"
  some metadata in object.get(after(resource), "metadata_options", [])
  object.get(metadata, "http_tokens", "optional") != "required"
  violation := {
    "policy_id": "SEC003",
    "category": "security",
    "severity": "high",
    "enforcement": "blocking",
    "resource": resource.address,
    "message": "EC2 Instance Metadata Service v2 must be required.",
    "remediation": "Set metadata_options.http_tokens to required."
  }
}
