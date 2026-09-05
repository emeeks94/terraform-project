#!/bin/bash

echo "===== FreshCart user-data version 2 ====="

set -euxo pipefail

exec > >(tee /var/log/freshcart-user-data.log | logger -t freshcart-user-data -s 2>/dev/console) 2>&1

echo "===== FreshCart startup beginning ====="

export DEBIAN_FRONTEND=noninteractive

apt-get update -y

echo "===== Installing prerequisites ====="

apt-get install -y curl unzip

echo "===== Installing Docker ====="

apt-get install -y docker.io docker-compose-v2

systemctl enable docker
systemctl start docker

echo "===== Docker installed ====="

echo "===== Installing AWS CLI v2 ====="

curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" \
  -o /tmp/awscliv2.zip

unzip -q /tmp/awscliv2.zip -d /tmp

/tmp/aws/install

echo "===== Versions ====="

aws --version
docker --version
docker compose version

echo "===== Docker installed ====="

mkdir -p /opt/freshcart

cat > /opt/freshcart/init.sql <<'SQL'
${db_init_sql}
SQL

cat > /opt/freshcart/docker-compose.yml <<'COMPOSE'
services:

  postgres:
    image: postgres:16
    container_name: freshcart-postgres
    restart: unless-stopped
    environment:
      POSTGRES_USER: freshcart
      POSTGRES_PASSWORD: freshcart
      POSTGRES_DB: freshcart
    volumes:
      - postgres-data:/var/lib/postgresql/data
      - /opt/freshcart/init.sql:/docker-entrypoint-initdb.d/init.sql
    networks:
      - freshcart-network

  checkout-api:
    image: ${checkout_api_image}
    container_name: checkout-api
    restart: unless-stopped
    depends_on:
      - postgres
    environment:
      DATABASE_URL: postgres://freshcart:freshcart@postgres:5432/freshcart
      PORT: 3000
    networks:
      - freshcart-network

  storefront:
    image: ${storefront_image}
    container_name: storefront
    restart: unless-stopped
    depends_on:
      - checkout-api
    ports:
      - "80:80"
    networks:
      - freshcart-network

volumes:
  postgres-data:

networks:
  freshcart-network:
COMPOSE

echo "===== Docker Compose configuration created ====="

AWS_REGION="us-east-1"
ECR_REGISTRY="699588737174.dkr.ecr.us-east-1.amazonaws.com"

echo "===== Logging into private ECR ====="

aws ecr get-login-password --region "$AWS_REGION" \
  | docker login --username AWS --password-stdin "$ECR_REGISTRY"

echo "===== Pulling FreshCart images ====="

docker pull "${checkout_api_image}"
docker pull "${storefront_image}"
docker pull postgres:16

echo "===== Starting FreshCart ====="

cd /opt/freshcart

docker compose up -d

echo "===== Container status ====="

docker compose ps

echo "===== FreshCart startup complete ====="
