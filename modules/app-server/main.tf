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
    connection {
      type        = "ssh"
      user        = "ubuntu"
      # --- ¡CAMBIO AQUÍ! Usar private_key directamente ---
      private_key = file("~/.ssh/${var.ssh_key_name}.pem") # Asegúrate de que la ruta y el nombre sean EXACTOS
      # agent       = true # <--- COMENTA O ELIMINA ESTA LÍNEA si usas private_key
      host        = self.public_ip
    }
    inline = [
      "pm2 start node /home/ubuntu/app/app.js --name 'unir-app-1'",
      "pm2 save",
      # Instalar Nginx
      "sudo apt-get install -y nginx",
      "sudo rm -f /etc/nginx/sites-enabled/default", # Eliminar sitio por defecto

      # Configurar la conexión a la base de datos (MongoDB) en el entorno de la app
      "echo 'DB_HOST=${var.db_private_ip}' | sudo tee -a /etc/environment",
      "echo 'DB_PORT=27017' | sudo tee -a /etc/environment",
    ]
  }

  # Provisioner para copiar el archivo de configuración de Nginx (ahora desde un archivo local)
  provisioner "file" {
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("~/.ssh/${var.ssh_key_name}.pem")
      host        = self.public_ip
    }
    source      = local_file.nginx_config.filename # <--- ¡AHORA APUNTA AL ARCHIVO LOCAL GENERADO!
    destination = "/tmp/mean_app.conf" # Copiamos a /tmp primero
  }

  # Provisioner para mover el archivo de Nginx y reiniciar el servicio
  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("~/.ssh/${var.ssh_key_name}.pem")
      host        = self.public_ip
    }
    inline = [
      "sudo mv /tmp/mean_app.conf /etc/nginx/sites-available/mean_app", # Mover a la ubicación final
      "sudo ln -s /etc/nginx/sites-available/mean_app /etc/nginx/sites-enabled/mean_app", # Crear symlink
      "sudo systemctl restart nginx" # Reiniciar Nginx
    ]
  }

  tags = {
    Name = "${var.project_name}-app-server"
  }
}

# --- ¡RECURSO LOCAL MOVIDO FUERA DEL BLOQUE aws_instance! ---
resource "local_file" "nginx_config" {
  content  = templatefile("${path.module}/templates/nginx_app.conf.tpl", { app_port = var.app_port })
  filename = "${path.module}/nginx_app.conf" # Archivo temporal local
}