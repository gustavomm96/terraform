# Lauch template configuration

# Vou usar o key pair que já tenho na aws
data "aws_key_pair" "kp_from_portal" {
  key_name = "keyEC2Linux" # Eu já tenho essa key pair na aws, o nome precisa ser exatamente igual
}

# AMI mais recente do Amazon Linux 2023 (x86_64)
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
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

# Criando o launch template
resource "aws_launch_template" "app" {
  provider      = aws.app
  name_prefix   = "lt-app-" # vai ser completado com o ID
  image_id      = data.aws_ami.amazon_linux_2023.id
  instance_type = "t3.micro"

  key_name = data.aws_key_pair.kp_from_portal.key_name

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [aws_security_group.app.id]
  }

  # Criado a role ssm para conseguir executar comandos e acesso via ssm
  iam_instance_profile {
    name = aws_iam_instance_profile.ssm.name
  }

  # user_data = base64encode(<<-EOF
  #             #!/bin/bash
  #             # Use this for your user data (script from top to bottom)
  #             # install httpd (Linux 2 version)
  #             yum update -y
  #             yum install -y httpd
  #             systemctl start httpd
  #             systemctl enable httpd
  #             echo "<h1>Hello World from $(hostname -f)</h1>" > /var/www/html/index.html
  #             EOF
  # )
  user_data = base64encode(
    templatefile("${path.module}/templates/user_data.sh.tpl", {
      rds_endpoint = aws_db_instance.mariadb.endpoint
      rds_username = aws_db_instance.mariadb.username
      rds_password = aws_db_instance.mariadb.password
      rds_dbname   = aws_db_instance.mariadb.db_name
      hostname     = "$(hostname -f)"
    })
  )

  tag_specifications {
    resource_type = "instance"


    tags = merge(local.common_tags, {
      os   = "Linux"
      type = "webserver"
      Name = "app-instance"
    })
  }

  lifecycle {
    create_before_destroy = true
  }
}