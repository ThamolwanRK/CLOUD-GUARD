package cloudguard

import rego.v1

violations contains violation if {
  some resource in active_resources
  resource.type == "aws_instance"
  instance_type := object.get(after(resource), "instance_type", "")
  not instance_type in data.approved_dev_instance_types
  violation := {
    "policy_id": "COST001",
    "category": "cost",
    "severity": "high",
    "enforcement": "blocking",
    "resource": resource.address,
    "message": sprintf("Instance type %s is not approved for the academic development environment.", [instance_type]),
    "remediation": sprintf("Use one of: %s.", [concat(", ", data.approved_dev_instance_types)])
  }
}

violations contains violation if {
  instances := [resource |
    some resource in active_resources
    resource.type == "aws_instance"
  ]
  count(instances) > 1
  violation := {
    "policy_id": "COST002",
    "category": "cost",
    "severity": "high",
    "enforcement": "blocking",
    "resource": "aws_instance",
    "message": sprintf("The prototype proposes %d EC2 instances; the approved maximum is one.", [count(instances)]),
    "remediation": "Reduce the development configuration to one EC2 instance."
  }
}

violations contains violation if {
  some resource in active_resources
  resource.type in {"aws_nat_gateway", "aws_lb", "aws_db_instance"}
  violation := {
    "policy_id": "COST003",
    "category": "cost",
    "severity": "medium",
    "enforcement": "warning",
    "resource": resource.address,
    "message": sprintf("Resource type %s can create recurring charges outside the approved prototype scope.", [resource.type]),
    "remediation": "Remove the resource or document and approve the additional cost before deployment."
  }
}
