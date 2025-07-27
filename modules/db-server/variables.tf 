# modules/db-server/variables.tf
# Este archivo define las variables de entrada para el módulo 'db-server'.

variable "project_name" {
  description = "Prefijo para nombrar los recursos."
  type        = string
}

variable "aws_region" {
  description = "La región de AWS."
  type        = string
}

variable "ami_id" {
  description = "El ID de la AMI para el servidor de base de datos."
  type        = string
}

variable "instance_type" {
  description = "Tipo de instancia EC2 para el servidor de base de datos."
  type        = string
}

variable "ssh_key_name" {
  description = "El nombre de la clave EC2 (Key Pair) existente en AWS."
  type        = string
}

variable "subnet_id" {
  description = "El ID de la subred privada donde se desplegará la DB."
  type        = string
}

variable "security_group_id" {
  description = "El ID del grupo de seguridad para el servidor de base de datos."
  type        = string
}