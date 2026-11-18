package cloudguard_test

import rego.v1

base_tags := {
  "Name": "cloudguard-dev-web",
  "Project": "CloudGuard",
  "Environment": "dev",
  "Owner": "student",
  "ManagedBy": "Terraform"
}

base_instance := {
  "address": "aws_instance.web",
  "type": "aws_instance",
  "change": {
    "actions": ["create"],
    "after": {
      "instance_type": "t3.micro",
      "root_block_device": [{"encrypted": true}],
      "metadata_options": [{"http_tokens": "required"}],
      "tags_all": base_tags
    }
  }
}

base_input(resources) := {
  "configuration": {
    "provider_config": {
      "aws": {"expressions": {"region": {"constant_value": "ap-south-1"}}}
    }
  },
  "resource_changes": resources
}

test_compliant_instance_is_allowed if {
  result := data.cloudguard.decision with input as base_input([base_instance])
  result.allow
  result.summary.blocking == 0
}

test_public_ssh_is_blocked if {
  ssh := {
    "address": "aws_vpc_security_group_ingress_rule.ssh",
    "type": "aws_vpc_security_group_ingress_rule",
    "change": {"actions": ["create"], "after": {"from_port": 22, "to_port": 22, "cidr_ipv4": "0.0.0.0/0"}}
  }
  result := data.cloudguard.decision with input as base_input([base_instance, ssh])
  not result.allow
  "SEC001" in {item.policy_id | some item in result.blocking_violations}
}

test_public_ipv6_all_protocols_is_blocked if {
  ingress := {
    "address": "aws_vpc_security_group_ingress_rule.all",
    "type": "aws_vpc_security_group_ingress_rule",
    "change": {"actions": ["create"], "after": {"ip_protocol": "-1", "cidr_ipv6": "::/0"}}
  }
  result := data.cloudguard.decision with input as base_input([base_instance, ingress])
  not result.allow
  "SEC001" in {item.policy_id | some item in result.blocking_violations}
}

test_unencrypted_instance_is_blocked if {
  bad := object.union(base_instance, {
    "change": object.union(base_instance.change, {
      "after": object.union(base_instance.change.after, {"root_block_device": [{"encrypted": false}]})
    })
  })
  result := data.cloudguard.decision with input as base_input([bad])
  "SEC002" in {item.policy_id | some item in result.blocking_violations}
}

test_optional_imdsv1_is_blocked if {
  bad := object.union(base_instance, {
    "change": object.union(base_instance.change, {
      "after": object.union(base_instance.change.after, {"metadata_options": [{"http_tokens": "optional"}]})
    })
  })
  result := data.cloudguard.decision with input as base_input([bad])
  "SEC003" in {item.policy_id | some item in result.blocking_violations}
}

test_missing_tags_are_blocked if {
  bad := {
    "address": "aws_instance.web",
    "type": "aws_instance",
    "change": {
      "actions": ["create"],
      "after": {
        "instance_type": "t3.micro",
        "root_block_device": [{"encrypted": true}],
        "metadata_options": [{"http_tokens": "required"}],
        "tags_all": {"Project": "CloudGuard"}
      }
    }
  }
  result := data.cloudguard.decision with input as base_input([bad])
  "GOV001" in {item.policy_id | some item in result.blocking_violations}
}

test_unapproved_region_is_blocked if {
  bad_input := object.union(base_input([base_instance]), {
    "configuration": {"provider_config": {"aws": {"expressions": {"region": {"constant_value": "us-east-1"}}}}}
  })
  result := data.cloudguard.decision with input as bad_input
  "GOV002" in {item.policy_id | some item in result.blocking_violations}
}

test_oversized_instance_is_blocked if {
  bad := object.union(base_instance, {
    "change": object.union(base_instance.change, {
      "after": object.union(base_instance.change.after, {"instance_type": "m7i.4xlarge"})
    })
  })
  result := data.cloudguard.decision with input as base_input([bad])
  "COST001" in {item.policy_id | some item in result.blocking_violations}
}

test_second_instance_is_blocked if {
  second := object.union(base_instance, {"address": "aws_instance.second"})
  result := data.cloudguard.decision with input as base_input([base_instance, second])
  "COST002" in {item.policy_id | some item in result.blocking_violations}
}

test_bad_name_warns_but_does_not_block if {
  legacy_tags := object.union(base_tags, {"Name": "legacy-web-name"})
  legacy := object.union(base_instance, {
    "change": object.union(base_instance.change, {
      "after": object.union(base_instance.change.after, {"tags_all": legacy_tags})
    })
  })
  result := data.cloudguard.decision with input as base_input([legacy])
  result.allow
  "GOV003" in {item.policy_id | some item in result.warnings}
}
