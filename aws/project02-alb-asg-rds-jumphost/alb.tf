# Target group
resource "aws_lb_target_group" "app" {
  provider = aws.app
  name     = "tg-gm-app"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.app.id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 10
    timeout             = 5
    interval            = 30
    path                = "/"
    matcher             = "200-399"
  }
}

# ALB - External
resource "aws_lb" "app" {
  name               = "alb-gm-app"
  internal           = false # false = ALB público
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = aws_subnet.app_public[*].id

  enable_deletion_protection = false

  tags = merge(local.common_tags, {
    Name = "alb-gm-app"
  })
}

# Configurando o listener na porta 80
resource "aws_lb_listener" "app_http" {
  load_balancer_arn = aws_lb.app.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}