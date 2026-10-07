# Coloquei como o bastion fazendo a solicitação que caso você uma rede maior o ideal seria concentrar as configurações de peering do lado do bastion para ficar organizado
# Tudo concentra no bastion, porque quando for acessar alguma coisa a primeira coisa que vou pensar é no bastion
# Após configurar o peering precisa configurar o route table e sg
# VPC Peering: requester (Bastion) -> accepter (app)
resource "aws_vpc_peering_connection" "bastion_app" {
  provider    = aws.bastion
  vpc_id      = aws_vpc.bastion.id
  peer_vpc_id = aws_vpc.app.id
  peer_region = "us-east-1" # Precisa passar a região do vpc que ele vai conectar, se não colocar isso, vai buscar a vpc na região errada

  auto_accept = false

  tags = merge(local.common_tags, {
    Name = "vpc-peering-bastion-to-app"
  })

}

# Aceite do peering na região do app
resource "aws_vpc_peering_connection_accepter" "app" {
  provider                  = aws.app
  vpc_peering_connection_id = aws_vpc_peering_connection.bastion_app.id
  auto_accept               = true


  tags = merge(local.common_tags, {
    Name = "vpc-peering-bastion-app"
    Side = "Accepter"
  })
}