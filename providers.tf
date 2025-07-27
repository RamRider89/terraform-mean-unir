# 1. providers.tf
# Este archivo define los proveedores de nube que Terraform utilizará.
# En este caso, configuramos el proveedor de Amazon Web Services (AWS).

provider "aws" {
  region  = var.aws_region # La region de AWS se toma de la variable global 'aws_region'.
  profile = "unir"
}