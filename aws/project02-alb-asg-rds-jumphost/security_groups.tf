# SG do ALB
resource "aws_security_group" "alb" {
  provider    = aws.app
  name        = "sg_alb"
  description = "Security group para o Application Load Balancer"
  vpc_id      = aws_vpc.app.id

  # Inbound: HTTP
  ingress {
    description = "HTTP from internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS
  # ingress {
  #   description = "HTTPS from internet"
  #   from_port   = 443
  #   to_port     = 443
  #   protocol    = "tcp"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }

  # Outbound: liberado para as instâncias
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sg_alb"
  }
}

# SG da aplicação EC2 - ASG
resource "aws_security_group" "app" {
  provider    = aws.app
  name        = "sg_app"
  description = "Security group para as instancias da aplicacao"
  vpc_id      = aws_vpc.app.id

  # Inbound: porta da aplicação vinda do ALB
  ingress {
    description     = "App port from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  # Inbound: SSH (temporario para meu ip, posteriormente, vou ter acesso apenas ao bastion)
  # ingress {
  #   description = "SSH from my home IP (temporario)"
  #   from_port   = 22
  #   to_port     = 22
  #   protocol    = "tcp"
  #   cidr_blocks = [var.allowed_admin_cidr]
  # }

  # SSH from bastion VPC
  ingress {
    description = "SSH from bastion VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.snet_cidr_bastion]
  }

  # Outbound: liberado para RDS e internet
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sg_app"
  }
}

# SG do RDS
resource "aws_security_group" "rds" {
  provider    = aws.app
  name        = "sg_rds"
  description = "Security group para o RDS"
  vpc_id      = aws_vpc.app.id

  # Inbound: porta do banco vinda do SG da aplicação
  ingress {
    description     = "MySQL/Aurora from app"
    from_port       = 3306 # de qualquer porta da aplicação
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.app.id]
  }

  # Outbound: liberado (padrão)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sg_rds"
  }
}

#----------------------------------------
# SG do bastion
resource "aws_security_group" "bastion" {
  provider    = aws.bastion
  name        = "sg_bastion"
  description = "Security group do bastion"
  vpc_id      = aws_vpc.bastion.id

  # Inbound: SSH da minha casa
  ingress {
    description = "SSH from my home IP"
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = [var.allowed_admin_cidr]
  }

  # Outbound: liberado para RDS e internet
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sg_bastion"
  }
}




