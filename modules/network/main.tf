# modules/network/main.tf
# Este archivo define los recursos de red y seguridad para el despliegue.

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "${var.project_name}-vpc"
  }
}

resource "aws_subnet" "public_az1" { # <--- Subred pública en AZ 'a'
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "${var.aws_region}a"
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.project_name}-public-subnet-az1"
  }
}

resource "aws_subnet" "public_az2" { # <--- ¡NUEVA! Subred pública en AZ 'b'
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.3.0/24" # CIDR diferente para la segunda subred pública
  availability_zone = "${var.aws_region}c"
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.project_name}-public-subnet-az2"
  }
}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "${var.aws_region}a" # Puede permanecer en una sola AZ si solo hay una DB
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

resource "aws_route_table_association" "public_az1" { # <--- Asociar primera subred pública
  subnet_id      = aws_subnet.public_az1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_az2" { # <--- ¡NUEVA! Asociar segunda subred pública
  subnet_id      = aws_subnet.public_az2.id
  route_table_id = aws_route_table.public.id
}

# --- NAT Gateway para acceso a Internet desde la subred privada ---
resource "aws_eip" "nat_gateway_eip" {
  #vpc        = true # Mantener si el proveedor es < 4.x, eliminar si es 4.x o >
  tags = {
    Name = "${var.project_name}-nat-eip"
  }
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_gateway_eip.id
  subnet_id     = aws_subnet.public_az1.id # El NAT Gateway reside en UNA subred pública
  tags = {
    Name = "${var.project_name}-nat-gateway"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw.id
  }
  tags = {
    Name = "${var.project_name}-private-rt"
  }
}

resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}

# --- Grupos de Seguridad ---

# Grupo de Seguridad para el Application Load Balancer (ALB)
resource "aws_security_group" "alb_sg" {
  name        = "${var.project_name}-alb-sg"
  description = "Permitir HTTP/HTTPS al ALB"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTP desde cualquier lugar"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS desde cualquier lugar"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-alb-sg"
  }
}

# Grupo de Seguridad para el Servidor de Aplicaciones (app-server-sg)
resource "aws_security_group" "app_server_sg" {
  name        = "${var.project_name}-app-server-sg"
  description = "Permitir HTTP/SSH desde mi IP y trafico del ALB"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTP desde ALB"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  ingress {
    description = "App Node.js desde ALB"
    from_port   = var.app_port
    to_port     = var.app_port
    protocol    = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  ingress {
    description = "SSH desde mi IP publica"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_public_ip]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-app-server-sg"
  }
}

# Grupo de Seguridad para el Servidor de Base de Datos (db-server-sg)
resource "aws_security_group" "db_server_sg" {
  name        = "${var.project_name}-db-server-sg"
  description = "Permitir MongoDB desde el servidor de aplicaciones y SSH desde mi IP"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "MongoDB desde el servidor de aplicaciones"
    from_port   = var.db_port
    to_port     = var.db_port
    protocol    = "tcp"
    security_groups = [aws_security_group.app_server_sg.id]
  }

  ingress {
    description = "SSH desde mi IP publica"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_public_ip]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-db-server"
  }
}

# --- Application Load Balancer (ALB) ---
resource "aws_lb" "main" {
  name               = "${var.project_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.public_az1.id, aws_subnet.public_az2.id] # <--- ¡AHORA USA AMBAS SUBREDES PÚBLICAS!

  tags = {
    Name = "${var.project_name}-alb"
  }
}

# Target Group para la aplicación Node.js
resource "aws_lb_target_group" "app_target_group" {
  name     = "${var.project_name}-app-tg"
  port     = var.app_port
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 5
    matcher             = "200"
  }

  tags = {
    Name = "${var.project_name}-app-tg"
  }
}

# Listener HTTP en el ALB (Puerto 80)
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_target_group.arn
  }
}

# Regla de Listener para el endpoint /alumnos
resource "aws_lb_listener_rule" "alumnos_rule" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 100
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_target_group.arn
  }
  condition {
    path_pattern {
      values = ["/alumnos", "/alumnos/*"]
    }
  }
}
