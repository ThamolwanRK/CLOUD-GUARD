package cloudguard

import rego.v1

active_resources := [resource |
  some resource in object.get(input, "resource_changes", [])
  actions := object.get(object.get(resource, "change", {}), "actions", [])
  actions != ["delete"]
]

after(resource) := object.get(object.get(resource, "change", {}), "after", {})

resource_tags(resource) := tags if {
  values := after(resource)
  tags := object.get(values, "tags_all", object.get(values, "tags", {}))
}

public_cidr(cidr) if {
  cidr in {"0.0.0.0/0", "::/0"}
}

port_exposed(values, _) if {
  object.get(values, "ip_protocol", object.get(values, "protocol", "")) == "-1"
}

port_exposed(values, port) if {
  port_range_contains(object.get(values, "from_port", null), object.get(values, "to_port", null), port)
}

port_range_contains(from_port, to_port, port) if {
  is_number(from_port)
  is_number(to_port)
  from_port <= port
  to_port >= port
}

taggable_type(resource_type) if {
  resource_type in {
    "aws_vpc",
    "aws_subnet",
    "aws_internet_gateway",
    "aws_route_table",
    "aws_security_group",
    "aws_instance",
    "aws_ebs_volume",
    "aws_s3_bucket"
  }
}

provider_region := region if {
  provider := object.get(object.get(object.get(input, "configuration", {}), "provider_config", {}), "aws", {})
  expression := object.get(object.get(provider, "expressions", {}), "region", {})
  region := object.get(expression, "constant_value", "")
}

violation_ids := {violation.policy_id | some violation in violations}
