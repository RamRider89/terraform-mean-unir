# modules/app-server/main.tf
# Este archivo define la instancia EC2 para el servidor de aplicaciones (Nginx + Node.js).

resource "aws_instance" "app_server" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = var.subnet_id
  vpc_security_group_ids = [var.security_group_id]
  key_name      = var.ssh_key_name # Clave SSH para acceso

  # Aprovisionamiento para configurar la aplicación Node.js y Nginx
  provisioner "remote-exec" {
    inline = [
      # Configurar la conexión a la base de datos (MongoDB) en el entorno de la app
      # Esto puede variar si la app usa un archivo de config o variables de entorno
      # Aquí un ejemplo para variables de entorno (si tu app las lee)
      "echo 'DB_HOST=${var.db_private_ip}' | sudo tee -a /etc/environment",
      "echo 'DB_PORT=${var.db_port}' | sudo tee -a /etc/environment",
      # Si tu app Node.js lee de .env, necesitarías copiar un .env o configurar de otra forma
    ]
  }

  tags = {
    Name = "${var.project_name}-app-server"
  }
}