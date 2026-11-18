resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${local.name_prefix}-vpc"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${local.name_prefix}-igw"
  }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr
  map_public_ip_on_launch = true

  tags = {
    Name = "${local.name_prefix}-public-subnet"
    Tier = "public"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${local.name_prefix}-public-rt"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "web" {
  name        = "${local.name_prefix}-web-sg"
  description = "CloudGuard demonstration web workload"
  vpc_id      = aws_vpc.main.id

  egress {
    description      = "Required for package installation and updates"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = []
  }

  tags = {
    Name = "${local.name_prefix}-web-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "http" {
  security_group_id = aws_security_group.web.id
  description       = "Public demonstration website"
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_ingress_rule" "node_exporter" {
  security_group_id = aws_security_group.web.id
  description       = "Prometheus scrape from the approved workstation"
  ip_protocol       = "tcp"
  from_port         = 9100
  to_port           = 9100
  cidr_ipv4         = var.monitoring_cidr
}

resource "aws_vpc_security_group_ingress_rule" "ssh" {
  count = var.enable_ssh ? 1 : 0

  security_group_id = aws_security_group.web.id
  description       = "Temporary SSH from one approved address"
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
  cidr_ipv4         = var.allowed_ssh_cidr
}
