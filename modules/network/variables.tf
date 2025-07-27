# modules/network/variables.tf
# Este archivo define las variables de entrada para el módulo 'network'.

variable "project_name" {
  description = "Prefijo para nombrar los recursos."
  type        = string
}

variable "aws_region" {
  description = "La region de AWS."
  type        = string
}

variable "my_public_ip" {
  description = "Tu direccion IP publica para acceso SSH."
  type        = string
}

variable "db_port" {
  description = "Puerto de la base de datos (MongoDB)."
  type        = number
}

variable "app_port" {
  description = "Puerto interno de la aplicación Node.js."
  type        = number
}