# modules/app-server/main.tf
# Este archivo define la instancia EC2 para el servidor de aplicaciones (Nginx + Node.js).

resource "aws_instance" "app_server" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = var.subnet_id
  vpc_security_group_ids = [var.security_group_id]
  key_name      = var.ssh_key_name # Clave SSH para acceso

  tags = {
    Name = "${var.project_name}-app-server"
  }
}