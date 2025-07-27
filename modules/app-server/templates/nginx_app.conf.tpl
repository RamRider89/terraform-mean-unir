server {
    listen 80;
    server_name _;

    location / {
        proxy_pass http://localhost:${app_port}; # Usamos variable de plantilla
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    # Regla específica para /alumnos
    location /alumnos {
        proxy_pass http://localhost:${app_port}/alumnos; # Redirige al endpoint /alumnos de la app
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}