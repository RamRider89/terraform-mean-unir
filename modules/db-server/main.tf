# modules/db-server/main.tf
# Este archivo define la instancia EC2 para el servidor de base de datos (MongoDB).

resource "aws_instance" "db_server" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = var.subnet_id
  vpc_security_group_ids = [var.security_group_id]
  key_name      = var.ssh_key_name # Clave SSH para acceso

  # Aprovisionamiento para instalar MongoDB
  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update -y",
      "sudo apt-get install -y gnupg curl",
      "curl -fsSL https://www.mongodb.org/static/pgp/server-6.0.asc | sudo gpg --dearmor -o /usr/share/keyrings/mongodb-archive-keyring.gpg",
      "echo 'deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/6.0 multiverse' | sudo tee /etc/apt/sources.list.d/mongodb-org-6.0.list",
      "sudo apt-get update -y",
      "sudo apt-get install -y mongodb-org",
      "sudo systemctl enable mongod",
      "sudo systemctl start mongod",
      "sudo sed -i 's/127.0.0.1/0.0.0.0/' /etc/mongod.conf", # Permitir conexiones desde cualquier IP
      "sudo systemctl restart mongod"
    ]
  }

  tags = {
    Name = "${var.project_name}-db-server"
  }
}