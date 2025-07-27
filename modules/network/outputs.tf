# modules/network/outputs.tf
# Este archivo define las salidas del módulo 'network'.

output "vpc_id" {
  description = "El ID de la VPC creada."
  value       = aws_vpc.main.id
}

output "public_subnet_id" {
  description = "El ID de la subred pública."
  value       = aws_subnet.public.id
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