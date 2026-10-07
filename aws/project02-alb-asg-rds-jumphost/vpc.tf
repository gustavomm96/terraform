
# Criar VPC principal
resource "aws_vpc" "app" {
  provider             = aws.app
  cidr_block           = var.vpc_cidr_main
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "vpc-app"
  }
}

# Criar Internet gateway
resource "aws_internet_gateway" "app" {
  provider = aws.app
  vpc_id   = aws_vpc.app.id

  tags = {
    Name = "igw-gm-app"
  }
}

# Subnets públicas (para o ALB)
resource "aws_subnet" "app_public" {
  provider = aws.app
  count    = length(var.availability_zones_main)

  vpc_id = aws_vpc.app.id
  #cidrsubnet(prefix, newbits, netnum)
  cidr_block              = cidrsubnet(var.vpc_cidr_main, 8, count.index) # = cidrsubnet("10.10.0.0/16", 8, 0) = 10.10.0.0/24 e cidrsubnet("10.10.0.0/16", 8, 1) = 10.10.1.0/24
  availability_zone       = var.availability_zones_main[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "subnet-app-public-${count.index + 1}"
    Type = "public"
  }
}

# Subnets privadas (para as instâncias da aplicação)
resource "aws_subnet" "app_private" {
  provider = aws.app
  count    = length(var.availability_zones_main)

  vpc_id            = aws_vpc.app.id
  cidr_block        = cidrsubnet(var.vpc_cidr_main, 8, count.index + 10) # +10 para não dar conflito 10.10.10.0/24 e 10.10.11.0/24
  availability_zone = var.availability_zones_main[count.index]

  tags = {
    Name = "subnet-app-private-${count.index + 1}"
    Type = "private"
  }
}

# Subnets privadas (para RDS)
resource "aws_subnet" "rds_private" {
  provider = aws.app
  count    = length(var.availability_zones_main)

  vpc_id            = aws_vpc.app.id
  cidr_block        = cidrsubnet(var.vpc_cidr_main, 8, count.index + 20)
  availability_zone = var.availability_zones_main[count.index]

  tags = {
    Name = "subnet-rds-private-${count.index + 1}"
    Type = "private"
  }
}


# ------------------------------------------------------------
# Oregon VPC - Configuration

# Criar VPC principal
resource "aws_vpc" "bastion" {
  provider             = aws.bastion # O provider que vai fazer ele criar na região de oregon
  cidr_block           = var.vpc_cidr_bastion
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "vpc-bastion"
  }
}

# Criar Internet gateway para o bastion
resource "aws_internet_gateway" "bastion" {
  provider = aws.bastion
  vpc_id   = aws_vpc.bastion.id

  tags = {
    Name = "igw-gm-bastion"
  }
}

# Subnet pública bastion
resource "aws_subnet" "bastion_public" {
  provider                = aws.bastion
  vpc_id                  = aws_vpc.bastion.id
  cidr_block              = var.snet_cidr_bastion
  availability_zone       = var.availability_zones_bastion
  map_public_ip_on_launch = true

  tags = {
    Name = "subnet-bastion-public"
    Type = "public"
  }
}