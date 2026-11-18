mock_provider "aws" {}

run "safe_default_infrastructure" {
  command = plan

  override_data {
    target = data.aws_ami.amazon_linux
    values = {
      id = "ami-0123456789abcdef0"
    }
  }

  assert {
    condition     = aws_instance.web.instance_type == "t3.micro"
    error_message = "The default EC2 instance must remain an approved micro size."
  }

  assert {
    condition     = aws_instance.web.root_block_device[0].encrypted
    error_message = "The EC2 root volume must be encrypted."
  }

  assert {
    condition     = aws_instance.web.metadata_options[0].http_tokens == "required"
    error_message = "IMDSv2 must be required."
  }

  assert {
    condition     = aws_vpc_security_group_ingress_rule.http.cidr_ipv4 == "0.0.0.0/0"
    error_message = "The demonstration website must remain reachable over HTTP."
  }

  assert {
    condition     = length(aws_vpc_security_group_ingress_rule.ssh) == 0
    error_message = "SSH must remain disabled by default."
  }

  assert {
    condition     = aws_vpc_security_group_ingress_rule.node_exporter.cidr_ipv4 == "127.0.0.1/32"
    error_message = "Node Exporter must default to a non-public monitoring CIDR."
  }
}
