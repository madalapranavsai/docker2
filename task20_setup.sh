#!/bin/bash

echo "🚀 Setting up Task 20 Environment..."
mkdir -p task20-overrides && cd task20-overrides
mkdir -p src
echo "<h1>Local Hot-Reload Dev Version</h1>" > src/index.html

# 1. THE BASE FILE
cat << 'EOF' > docker-compose.yml
version: '3.8'
services:
  app:
    image: nginx:alpine
    container_name: web_app
EOF

# 2. THE DEV OVERRIDE
cat << 'EOF' > docker-compose.override.yml
version: '3.8'
services:
  app:
    ports:
      - "8080:80"
    volumes:
      - ./src:/usr/share/nginx/html
    environment:
      - APP_ENV=development
      - DEBUG_MODE=true
EOF

# 3. THE PROD OVERRIDE
cat << 'EOF' > docker-compose.prod.yml
version: '3.8'
services:
  app:
    ports:
      - "80:80"
    environment:
      - APP_ENV=production
      - DEBUG_MODE=false
    deploy:
      resources:
        limits:
          cpus: '0.50'
          memory: 256M
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
EOF

echo -e "\n============================================="
echo "🛠️  PHASE 1: TESTING DEVELOPMENT MODE"
echo "Command: docker compose up -d"
echo "============================================="
docker compose up -d
sleep 2

echo -e "\n🔍 Checking Dev Environment Variable:"
docker exec web_app env | grep APP_ENV

echo -e "\n🌐 Checking Dev Bind Mount & Port (localhost:8080):"
curl -s localhost:8080

echo -e "\n🧹 Tearing down Dev Environment..."
docker compose down


echo -e "\n============================================="
echo "🔒 PHASE 2: TESTING PRODUCTION MODE"
echo "Command: docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d"
echo "============================================="
docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d
sleep 2

echo -e "\n🔍 Checking Prod Environment Variable:"
docker exec web_app env | grep APP_ENV

echo -e "\n🛡️  Checking Prod Memory Limits (Should be 268435456 bytes / 256M):"
docker inspect web_app | grep -A 1 '"Memory":'

echo -e "\n🧹 Tearing down Prod Environment..."
docker compose down

echo -e "\n✅ Task 20 Demonstration Complete!"
