package cloudguard

import rego.v1

violations contains violation if {
  some resource in active_resources
  taggable_type(resource.type)
  tags := resource_tags(resource)
  missing := [tag |
    some tag in data.required_tags
    trim_space(object.get(tags, tag, "")) == ""
  ]
  count(missing) > 0
  violation := {
    "policy_id": "GOV001",
    "category": "governance",
    "severity": "high",
    "enforcement": "blocking",
    "resource": resource.address,
    "message": sprintf("Required tags are missing or empty: %s.", [concat(", ", missing)]),
    "remediation": "Add Project, Environment, Owner, and ManagedBy tags."
  }
}

violations contains violation if {
  provider_region != ""
  not provider_region in data.approved_regions
  violation := {
    "policy_id": "GOV002",
    "category": "governance",
    "severity": "high",
    "enforcement": "blocking",
    "resource": "provider.aws",
    "message": sprintf("AWS region %s is not approved.", [provider_region]),
    "remediation": sprintf("Use one of the approved regions: %s.", [concat(", ", data.approved_regions)])
  }
}

violations contains violation if {
  some resource in active_resources
  taggable_type(resource.type)
  name := object.get(resource_tags(resource), "Name", "")
  name != ""
  not regex.match("^cloudguard-(dev|test)-[a-z0-9-]+$", name)
  violation := {
    "policy_id": "GOV003",
    "category": "governance",
    "severity": "medium",
    "enforcement": "warning",
    "resource": resource.address,
    "message": sprintf("Resource name %s does not follow the CloudGuard convention.", [name]),
    "remediation": "Use cloudguard-<environment>-<purpose>."
  }
}
