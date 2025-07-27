# 3. main.tf
# Este es el archivo principal del módulo raíz que orquesta el despliegue
# de los módulos hijos (red, servidor de base de datos, servidor de aplicaciones).

# Módulo de red y seguridad
module "network" {
  source = "./modules/network" # Ruta al módulo de red

  project_name = var.project_name
  aws_region   = var.aws_region
  my_public_ip = var.my_public_ip
  db_port      = var.db_port
  app_port     = var.app_port
}

# Módulo del servidor de base de datos
module "db_server" {
  source = "./modules/db-server" # Ruta al módulo del servidor de base de datos

  project_name      = var.project_name
  aws_region        = var.aws_region
  ami_id            = var.ami_db_server
  instance_type     = var.instance_type_db
  ssh_key_name      = var.ssh_key_name
  subnet_id         = module.network.private_subnet_id    # Salida del módulo de red
  security_group_id = module.network.db_security_group_id # Salida del módulo de red
}

# Módulo del servidor de aplicaciones
module "app_server" {
  source = "./modules/app-server" # Ruta al módulo del servidor de aplicaciones

  project_name      = var.project_name
  aws_region        = var.aws_region
  ami_id            = var.ami_app_server
  instance_type     = var.instance_type_app
  ssh_key_name      = var.ssh_key_name
  subnet_id         = module.network.public_subnet_id      # Salida del módulo de red
  security_group_id = module.network.app_security_group_id # Salida del módulo de red
  db_private_ip     = module.db_server.private_ip          # Salida del módulo de base de datos
  app_port          = var.app_port
}

# Opcional: Salidas del módulo raíz para facilitar el acceso a la información
output "app_public_ip" {
  description = "La IP pública del servidor de aplicaciones."
  value       = module.app_server.public_ip
}

output "db_private_ip" {
  description = "La IP privada del servidor de base de datos."
  value       = module.db_server.private_ip
}
