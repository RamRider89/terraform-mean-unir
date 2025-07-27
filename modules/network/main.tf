# modules/network/main.tf
# Este archivo define los recursos de red y seguridad para el despliegue.

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16" # Rango de IP para tu VPC
  tags = {
    Name = "${var.project_name}-vpc"
  }
}

resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24" # Subred para el servidor de aplicaciones (pública)
  availability_zone = "${var.aws_region}a" # Usar una AZ específica
  map_public_ip_on_launch = true # Asignar IP pública automáticamente
  tags = {
    Name = "${var.project_name}-public-subnet"
  }
}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24" # Subred para el servidor de base de datos (privada)
  availability_zone = "${var.aws_region}a" # Usar la misma AZ
  tags = {
    Name = "${var.project_name}-private-subnet"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.project_name}-igw"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = {
    Name = "${var.project_name}-public-rt"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# --- Grupos de Seguridad ---

# Grupo de Seguridad para el Servidor de Aplicaciones (app-server-sg)
resource "aws_security_group" "app_server_sg" {
  name        = "${var.project_name}-app-server-sg"
  description = "Permitir HTTP, HTTPS y SSH para el servidor de aplicaciones"
  vpc_id      = aws_vpc.main.id

  # Regla para HTTP (Puerto 80)
  ingress {
    description = "HTTP desde cualquier lugar"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Acceso público
  }

  # Regla para SSH (Puerto 22)
  ingress {
    description = "SSH desde mi IP pública"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_public_ip] # Tu IP pública
  }

  # Regla para la aplicación Node.js (Puerto 3000) - si se accede directamente
  ingress {
    description = "App Node.js desde mi IP pública"
    from_port   = var.app_port
    to_port     = var.app_port
    protocol    = "tcp"
    cidr_blocks = [var.my_public_ip] # Tu IP pública
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # Todo el tráfico saliente
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-app-server-sg"
  }
}

# Grupo de Seguridad para el Servidor de Base de Datos (db-server-sg)
resource "aws_security_group" "db_server_sg" {
  name        = "${var.project_name}-db-server-sg"
  description = "Permitir MySQL/MongoDB desde el servidor de aplicaciones y SSH desde mi IP"
  vpc_id      = aws_vpc.main.id

  # Regla para MongoDB (Puerto 27017)
  ingress {
    description = "MongoDB desde el servidor de aplicaciones"
    from_port   = var.db_port
    to_port     = var.db_port
    protocol    = "tcp"
    security_groups = [aws_security_group.app_server_sg.id] # Solo desde el SG de la app
  }

  # Regla para SSH (Puerto 22)
  ingress {
    description = "SSH desde mi IP pública"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_public_ip] # Tu IP pública
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # Todo el tráfico saliente
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-db-server-sg"
  }
}