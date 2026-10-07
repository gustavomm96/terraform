# Encontrar o a image para o bastion
data "aws_ami" "windows_bastion" {
  provider    = aws.bastion
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["Windows_Server-2022-English-Full-Base-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

# Criando o bastion windows
resource "aws_instance" "bastion" {
  provider = aws.bastion

  ami                    = data.aws_ami.windows_bastion.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.bastion_public.id
  vpc_security_group_ids = [aws_security_group.bastion.id]
  key_name               = "keyEC2Windows_Oregon" # já tenho essa key na aws, apenas referencio o nome exato OBS: Key são regionais na aws

  root_block_device {
    volume_size = 30
    volume_type = "gp2"
  }

  tags = merge(local.common_tags, {
    Name = "bastion-windows"
  })
}