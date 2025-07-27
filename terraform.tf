# 1. providers.tf
# Este archivo define los proveedores de nube que Terraform utilizará.
# En este caso, configuramos el proveedor de Amazon Web Services (AWS).

terraform {
  required_version = ">= 1.5.0" # Versión mínima de Terraform CLI requerida

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0" # Versión mínima del proveedor AWS
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
    local = { # <--- ¡AÑADIDO: Proveedor 'local' requerido para local_file!
      source  = "hashicorp/local"
      version = "~> 2.0" # Versión compatible para el proveedor local
    }
  }
}