# Lauch template
output "lt_name" {
  description = "Launch template name"
  value       = aws_launch_template.app.name
}
# ASG
output "asg_name" {
  description = "ASG name"
  value       = aws_autoscaling_group.app.name
}
# Informações o NAT Gateway IP
output "eip_address" {
  description = "EIP do Nat Gateway"
  value       = aws_eip.nat.public_ip
}

# ALB
output "alb_dns_name" {
  description = "DNS name do Application Load Balancer"
  value       = aws_lb.app.dns_name
}

# Informações do RDB
output "rds_endpoint" {
  description = "Endpoint do RDS MariaDB"
  value       = aws_db_instance.mariadb.endpoint
}

output "rds_username" {
  description = "Usuário mestre do RDS"
  value       = aws_db_instance.mariadb.username
  sensitive   = true
}

output "bastion_public_ip" {
  description = "Bastion IP publico"
  value       = aws_instance.bastion.public_ip
}

# Teste simples: outputs para confirmar IDs e regiões
output "app_vpc_id" {
  value = aws_vpc.app.id
}

output "bastion_vpc_id" {
  value = aws_vpc.bastion.id
}