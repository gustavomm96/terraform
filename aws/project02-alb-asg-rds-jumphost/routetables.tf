# Route table pública (com rota para IGW)
resource "aws_route_table" "app_public" {
  provider = aws.app
  vpc_id   = aws_vpc.app.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.app.id
  }

  tags = {
    Name = "rt-app-public"
  }
}

# Associar route table pública às subnets públicas
resource "aws_route_table_association" "app_public" {
  count = length(var.availability_zones_main)

  subnet_id      = aws_subnet.app_public[count.index].id
  route_table_id = aws_route_table.app_public.id
}

# Route table privada - com rota privada para o NAT gw - sem nenhum acesso para internet, não consigo atualizar s.o, instalar pacotes ou instalar SSM
resource "aws_route_table" "app_private" {
  provider = aws.app
  vpc_id   = aws_vpc.app.id

  # Rota para
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }

  tags = {
    Name = "rt-app-private"
  }
}

# Associar subnets privadas a route table privada
resource "aws_route_table_association" "app_private" {
  count = length(var.availability_zones_main)

  subnet_id      = aws_subnet.app_private[count.index].id
  route_table_id = aws_route_table.app_private.id
}

# Criar route table para RDS subnet
resource "aws_route_table" "rds_private" {
  provider = aws.app
  vpc_id   = aws_vpc.app.id

  tags = {
    Name = "rt-rds-private"
  }
}

# Associar a route table RDS com a Subnet RDS
resource "aws_route_table_association" "rds_private" {
  count = length(var.availability_zones_main)

  subnet_id      = aws_subnet.rds_private[count.index].id
  route_table_id = aws_route_table.rds_private.id
}

# ------------------------------------------------------------
# Oregon VPC - Configuration

# Route table pública do bastion (com rota para IGW)
resource "aws_route_table" "bastion_public" {
  provider = aws.bastion
  vpc_id   = aws_vpc.bastion.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.bastion.id
  }

  tags = {
    Name = "rt-bastion-public"
  }
}

# Associar route table pública do bastion a subnet pública do bastion
resource "aws_route_table_association" "bastion_public" {
  provider       = aws.bastion
  subnet_id      = aws_subnet.bastion_public.id
  route_table_id = aws_route_table.bastion_public.id
}

# criar as rotas entre o peering Regiao A para B
resource "aws_route" "app_to_bastion" {
  provider               = aws.app
  route_table_id         = aws_route_table.app_private.id
  destination_cidr_block = var.vpc_cidr_bastion # É o CIDR do bastion para ele saber que quando procurar 172.16.0.0/16 ele pergunta para o peering
  #vpc_peering_connection_id = aws_vpc_peering_connection.app_bastion.id
  vpc_peering_connection_id = aws_vpc_peering_connection.bastion_app.id
}

resource "aws_route" "bastion_to_app" {
  provider               = aws.bastion
  route_table_id         = aws_route_table.bastion_public.id
  destination_cidr_block = var.vpc_cidr_main
  #vpc_peering_connection_id = aws_vpc_peering_connection.app_bastion.id
  vpc_peering_connection_id = aws_vpc_peering_connection.bastion_app.id
}