# modules/network — VPC mínima MWAA + S3 Gateway Endpoint (NFR: menos tráfego via NAT).

variable "name_prefix" {
  type        = string
  description = "Prefixo de nomes/tags."
}

variable "vpc_cidr" {
  type = string
}

variable "public_subnet_cidr" {
  type = string
}

variable "private_subnet_cidrs" {
  type = list(string)
}

variable "aws_region" {
  type = string
}

data "aws_availability_zones" "available" {
  state = "available"
}

# VPC com DNS — MWAA e resolution de endpoints exigem DNS hostnames.
resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.name_prefix}vpc"
  }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
  tags   = { Name = "${var.name_prefix}igw" }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.name_prefix}public-a"
    Tier = "public"
  }
}

resource "aws_subnet" "private" {
  count = 2

  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "${var.name_prefix}private-${count.index}"
    Tier = "private"
  }
}

# EIP + NAT único — CostGuardrail PoC (SPOF consciente).
resource "aws_eip" "nat" {
  domain = "vpc"
  tags   = { Name = "${var.name_prefix}nat-eip" }
}

resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public.id
  tags          = { Name = "${var.name_prefix}nat" }

  depends_on = [aws_internet_gateway.this]
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  tags   = { Name = "${var.name_prefix}rt-public" }
}

resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id
  tags   = { Name = "${var.name_prefix}rt-private" }
}

resource "aws_route" "private_nat" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this.id
}

resource "aws_route_table_association" "private" {
  count = 2

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

# S3 Gateway Endpoint — tráfego S3 das subnets privadas sem hairpin no NAT.
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.this.id
  service_name      = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [aws_route_table.private.id]

  tags = { Name = "${var.name_prefix}vpce-s3" }
}

# SG MWAA: self-reference obrigatório para workers/scheduler (guia AWS MWAA).
resource "aws_security_group" "mwaa" {
  name        = "${var.name_prefix}mwaa-sg"
  description = "Security group for MWAA environment"
  vpc_id      = aws_vpc.this.id

  tags = { Name = "${var.name_prefix}mwaa-sg" }
}

resource "aws_security_group_rule" "mwaa_self_ingress" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.mwaa.id
  source_security_group_id = aws_security_group.mwaa.id
  description              = "MWAA self-referencing ingress"
}

resource "aws_security_group_rule" "mwaa_egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.mwaa.id
  description       = "Allow egress for package downloads and AWS APIs"
}

output "vpc_id" {
  value = aws_vpc.this.id
}

output "public_subnet_id" {
  value = aws_subnet.public.id
}

output "private_subnet_ids" {
  value = aws_subnet.private[*].id
}

output "mwaa_security_group_id" {
  value = aws_security_group.mwaa.id
}
