# terraform-mean-unir
## Actividad grupal
### Despliegue de MEAN multicapa mediante Terraform

# estructura
.
├── main.tf                     # Orquestador principal
├── variables.tf                # Variables globales
├── modules/
│   ├── network/                # Módulo 1: Red y Seguridad
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── db-server/              # Módulo 2: Servidor de Base de Datos
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── app-server/             # Módulo 3: Servidor de Aplicaciones
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
└── providers.tf                # Configuración del proveedor de AWS