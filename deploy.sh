#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

echo "🚀 Starting Automated SRE Capstone Deployment..."

# 1. Create and enter the workspace
echo "📁 Creating workspace directory 'task30-capstone'..."
mkdir -p task30-capstone
cd task30-capstone

# 2. Generate the Dockerfile
echo "📄 Generating Dockerfile..."
cat << 'EOF' > Dockerfile
# ==========================================
# STAGE 1: The Git Builder (CI/CD Phase)
# ==========================================
FROM alpine:3.19 AS builder
RUN apk add --no-cache git
WORKDIR /build
RUN git clone --depth 1 https://github.com/wordpress/wordpress.git .
RUN rm -rf .git

# ==========================================
# STAGE 2: Secure Production Runtime
# ==========================================
FROM php:8.2-fpm-alpine
LABEL maintainer="SRE Capstone Engineer"

RUN apk add --no-cache fcgi freetype-dev libjpeg-turbo-dev libpng-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd mysqli opcache \
    && rm -rf /var/cache/apk/*

RUN echo "ping.path = /ping" >> /usr/local/etc/php-fpm.d/zz-docker.conf
WORKDIR /var/www/html
COPY --from=builder --chown=www-data:www-data /build /var/www/html
USER www-data

HEALTHCHECK --interval=10s --timeout=5s --retries=3 \
  CMD SCRIPT_NAME=/ping SCRIPT_FILENAME=/ping REQUEST_METHOD=GET cgi-fcgi -bind -connect 127.0.0.1:9000 || exit 1

EXPOSE 9000
CMD ["php-fpm"]
EOF

# 3. Generate docker-compose.yml
echo "📄 Generating docker-compose.yml..."
cat << 'EOF' > docker-compose.yml
version: '3.8'

x-logging: &default-logging
  driver: "json-file"
  options:
    max-size: "10m"
    max-file: "3"

services:
  db:
    image: mariadb:10.11
    container_name: wp_git_db
    restart: unless-stopped
    environment:
      MYSQL_ROOT_PASSWORD: ${DB_ROOT_PASSWORD}
      MYSQL_DATABASE: ${DB_NAME}
      MYSQL_USER: ${DB_USER}
      MYSQL_PASSWORD: ${DB_PASSWORD}
    volumes:
      - db_data:/var/lib/mysql
    networks:
      - backend_net
    logging: *default-logging
    healthcheck:
      test: ["CMD", "healthcheck.sh", "--connect", "--innodb_initialized"]
      interval: 10s
      timeout: 5s
      retries: 5
    deploy:
      resources:
        limits:
          cpus: '1.00'
          memory: 512M

  app:
    build: .
    container_name: wp_git_app
    restart: unless-stopped
    environment:
      WORDPRESS_DB_HOST: db
      WORDPRESS_DB_NAME: ${DB_NAME}
      WORDPRESS_DB_USER: ${DB_USER}
      WORDPRESS_DB_PASSWORD: ${DB_PASSWORD}
    volumes:
      - wp_data:/var/www/html
    networks:
      - backend_net
    depends_on:
      db:
        condition: service_healthy
    logging: *default-logging
    deploy:
      resources:
        limits:
          cpus: '1.00'
          memory: 256M

  web:
    image: nginx:alpine
    container_name: wp_git_nginx
    restart: unless-stopped
    ports:
      - "${HTTP_PORT}:80"
    volumes:
      - wp_data:/var/www/html:ro
      - ./nginx.conf:/etc/nginx/conf.d/default.conf:ro
    networks:
      - backend_net
    depends_on:
      app:
        condition: service_healthy
    logging: *default-logging
    healthcheck:
      test: ["CMD", "wget", "-q", "-O", "-", "http://localhost"]
      interval: 10s
      timeout: 5s
      retries: 3
    deploy:
      resources:
        limits:
          cpus: '0.50'
          memory: 128M

networks:
  backend_net:
    driver: bridge

volumes:
  db_data:
  wp_data:
EOF

# 4. Generate nginx.conf
echo "📄 Generating nginx.conf..."
cat << 'EOF' > nginx.conf
server {
    listen 80;
    server_name localhost;
    root /var/www/html;
    index index.php index.html;

    add_header X-Frame-Options "SAMEORIGIN";
    add_header X-XSS-Protection "1; mode=block";
    add_header X-Content-Type-Options "nosniff";

    location ~ /\. {
        deny all;
    }

    location / {
        try_files $uri $uri/ /index.php?$args;
    }

    location ~ \.php$ {
        fastcgi_pass app:9000;
        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
    }
}
EOF

# 5. Generate .env.example
echo "📄 Generating .env.example..."
cat << 'EOF' > .env.example
HTTP_PORT=8080
DB_ROOT_PASSWORD=super_secret_root_pass
DB_NAME=wordpress_prod
DB_USER=wp_admin
DB_PASSWORD=secure_wp_pass_123!
EOF

# 6. Generate Makefile
echo "📄 Generating Makefile..."
cat << 'EOF' > Makefile
.PHONY: build up down logs status backup restore clean

build:
	@echo "🔨 Cloning directly from GitHub & Building Image..."
	docker compose build

up:
	@echo "🚀 Deploying Zero-Trust Architecture..."
	docker compose up -d

down:
	@echo "🛑 Tearing down stack safely..."
	docker compose down

logs:
	docker compose logs -f

status:
	docker compose ps

backup:
	@echo "💾 Dumping Database to backup.sql..."
	docker exec wp_git_db sh -c 'exec mariadb-dump --all-databases -uroot -p"$$MYSQL_ROOT_PASSWORD"' > backup.sql
	@echo "✅ Backup complete!"

restore:
	@echo "🔄 Restoring Database from backup.sql..."
	docker exec -i wp_git_db sh -c 'exec mariadb -uroot -p"$$MYSQL_ROOT_PASSWORD"' < backup.sql
	@echo "✅ Restore complete!"

clean:
	@echo "🧹 Removing volumes and orphaned images..."
	docker compose down -v
	docker image prune -f
EOF

# 7. Generate README.md
echo "📄 Generating README.md..."
cat << 'EOF' > README.md
# SRE Capstone: Git-Sourced WordPress Architecture
Automated GitOps-style containerization of WordPress bypassing monolithic official images.
EOF

# 8. Setup Secrets
echo "🔐 Setting up environment secrets..."
cp .env.example .env

# 9. Execute the Build (CI/CD Phase)
echo "============================================="
echo "⚙️  PHASE 1: Fetching code from GitHub & Building..."
echo "============================================="
make build

# 10. Boot the Stack
echo "============================================="
echo "⚙️  PHASE 2: Orchestrating the Stack..."
echo "============================================="
make up

echo "============================================="
echo "✅ DEPLOYMENT INITIATED!"
echo "The architecture is booting. Health checks will synchronize the startup."
echo "Run 'make status' in the task30-capstone directory to monitor progress."
echo "Once all containers are (healthy), visit: http://localhost:8080"
echo "============================================="
