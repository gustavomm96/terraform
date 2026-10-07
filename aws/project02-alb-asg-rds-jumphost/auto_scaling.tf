resource "aws_autoscaling_group" "app" {
  provider    = aws.app
  name_prefix = "asg-app-"
  # vai usar as duas vpcs private criadas anteriormente, com isso fica em AZs distintas as vms
  vpc_zone_identifier = [
    aws_subnet.app_private[0].id,
    aws_subnet.app_private[1].id
  ]

  min_size         = 1
  max_size         = 2
  desired_capacity = 1

  health_check_type         = "ELB" # usa health check do ALB
  health_check_grace_period = 300   # 5 minutos para a instância subir

  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest" # Em produção é o ideal setar e nem sempra usar a ultima
  }

  # Target group do ALB (você cria depois)
  target_group_arns = [aws_lb_target_group.app.arn]

  # propagar tags para as instâncias
  tag {
    key                 = "Name"
    value               = "app-instance"
    propagate_at_launch = true
  }

  # Vai ignorar certas mudanças aplicadas no codigo depois do deploy
  lifecycle {
    ignore_changes = [
      desired_capacity,
      min_size,
      max_size,
      #target_group_arns,
    ]
  }
}

# -------------------------------------
# Regras de scale out e scale in

# Alarme de CPU alta -> scale out
resource "aws_autoscaling_policy" "app_scale_out" {
  name                   = "app-scale-out-cpu"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.app.name
}

# Alarme no cloud watch para monitorar alto cpu 
resource "aws_cloudwatch_metric_alarm" "app_cpu_high" {
  alarm_name          = "app-cpu-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = 70
  alarm_description   = "Escalar para cima quando CPU >= 70%"
  alarm_actions       = [aws_autoscaling_policy.app_scale_out.arn]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.app.name
  }
}

# Alarme de CPU baixa -> scale in
resource "aws_autoscaling_policy" "app_scale_in" {
  name                   = "app-scale-in-cpu"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.app.name
}

# Alarme no cloud watch para monitorar consumo baixo de cpu
resource "aws_cloudwatch_metric_alarm" "app_cpu_low" {
  alarm_name          = "app-cpu-low"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = 30
  alarm_description   = "Escalar para baixo quando CPU <= 30%"
  alarm_actions       = [aws_autoscaling_policy.app_scale_in.arn]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.app.name
  }
}
