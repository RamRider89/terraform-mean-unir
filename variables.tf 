# 2. variables.tf
# Este archivo contiene las definiciones de las variables globales para el módulo raíz.
# Estos valores serán pasados a los módulos hijos.

variable "aws_region" {
  description = "La región de AWS donde se desplegará la infraestructura."
  type        = string
  default     = "us-west-1" # Puedes cambiar esta región por tu preferencia.
}

variable "project_name" {
  description = "Prefijo para nombrar los recursos de AWS y evitar conflictos."
  type        = string
  default     = "mean-stack-unir"
}

variable "my_public_ip" {
  description = "Tu dirección IP pública para permitir el acceso SSH y HTTP/S a las instancias."
  type        = string
  # ¡IMPORTANTE! Reemplaza esto con tu IP pública actual seguida de /32 (ej. "203.0.113.45/32").
  # Puedes obtener tu IP con 'curl ifconfig.me' o 'whatismyip.com'.
  default     = "0.0.0.0/0" # ¡ADVERTENCIA! Usar 0.0.0.0/0 para SSH es INSEGURO en producción.
}

variable "ami_app_server" {
  description = "El ID de la AMI para el servidor de aplicaciones (Node.js + Nginx) construida con Packer."
  type        = string
  # ¡IMPORTANTE! Reemplaza esto con el AMI ID real que generaste con Packer.
  # Ejemplo: "ami-0abcdef1234567890"
  default     = "ami-0033f2a69c6bb01d7" # AMI de Ubuntu 24.04 LTS
}

variable "ami_db_server" {
  description = "El ID de la AMI para el servidor de base de datos (MongoDB). Puede ser una base Ubuntu o una preconfigurada."
  type        = string
  # ¡IMPORTANTE! Reemplaza esto con el AMI ID real.
  # Ejemplo: "ami-0abcdef1234567890"
  default     = "ami-0a89104a1ccdc51c0" # AMI de Ubuntu 24.04 LTS
}

variable "instance_type_app" {
  description = "Tipo de instancia EC2 para el servidor de aplicaciones."
  type        = string
  default     = "t3.micro"
}

variable "instance_type_db" {
  description = "Tipo de instancia EC2 para el servidor de base de datos."
  type        = string
  default     = "t3.micro"
}

variable "db_port" {
  description = "Puerto por defecto para la base de datos (MongoDB)."
  type        = number
  default     = 27017 # Puerto por defecto de MongoDB
}

variable "app_port" {
  description = "Puerto interno de la aplicación Node.js."
  type        = number
  default     = 3000 # Puerto interno de la aplicación Express/Node.js
}

variable "ssh_key_name" {
  description = "El nombre de la clave EC2 (Key Pair) existente en AWS para acceso SSH."
  type        = string
  # ¡IMPORTANTE! Reemplaza esto con el nombre de tu Key Pair en AWS.
  default     = "mongo-unir-keys"
}