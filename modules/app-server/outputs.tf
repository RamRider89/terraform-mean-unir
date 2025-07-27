# modules/app-server/outputs.tf
# Este archivo define las salidas del módulo 'app-server'.

output "public_ip" {
  description = "La IP publica del servidor de aplicaciones."
  value       = aws_instance.app_server.public_ip
}
