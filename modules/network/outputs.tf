# modules/network/outputs.tf
# Este archivo define las salidas del módulo 'network'.

output "vpc_id" {
  description = "El ID de la VPC creada."
  value       = aws_vpc.main.id
}

output "public_subnet_ids" { # <--- ¡CAMBIO! Ahora es una lista de IDs
  description = "Los IDs de las subredes publicas."
  value       = [aws_subnet.public_az1.id, aws_subnet.public_az2.id]
}

output "private_subnet_id" {
  description = "El ID de la subred privada."
  value       = aws_subnet.private.id
}

output "app_security_group_id" {
  description = "El ID del grupo de seguridad para el servidor de aplicaciones."
  value       = aws_security_group.app_server_sg.id
}

output "db_security_group_id" {
  description = "El ID del grupo de seguridad para el servidor de base de datos."
  value       = aws_security_group.db_server_sg.id
}

output "alb_dns_name" {
  description = "El nombre DNS del Application Load Balancer."
  value       = aws_lb.main.dns_name
}

output "nat_gateway_public_ip" {
  description = "La IP pública del NAT Gateway."
  value       = aws_eip.nat_gateway_eip.public_ip
}

output "app_target_group_arn" {
  description = "El ARN del Target Group del ALB para la aplicacion."
  value       = aws_lb_target_group.app_target_group.arn
}
