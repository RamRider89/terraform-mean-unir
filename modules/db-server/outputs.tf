# modules/db-server/outputs.tf
# Este archivo define las salidas del módulo 'db-server'.

output "private_ip" {
  description = "La IP privada del servidor de base de datos."
  value       = aws_instance.db_server.private_ip
}

# Ya teníamos esta salida, no hay cambios aquí.
# output "public_ip" {
#   description = "La IP pública del servidor de base de datos."
#   value       = aws_instance.db_server.public_ip
# }
