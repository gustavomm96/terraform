# Criar IP publico do nat gw
resource "aws_eip" "nat" {
  provider = aws.app
  domain   = "vpc"
  tags = merge(local.common_tags, {
    Name = "eip-nat-gw-gm"
  })
}

# Criar NAT Gateway
resource "aws_nat_gateway" "main" {
  provider      = aws.app
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.app_public[0].id

  tags = merge(local.common_tags, {
    Name = "nat-gw-gm"
  })
}
