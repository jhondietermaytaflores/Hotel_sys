#!/bin/bash
# Instalar Docker y Docker Compose

sudo yum update -y

sudo yum install -y docker
sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -aG docker opc

# Instalar Docker Compose v2
sudo curl -L "https://github.com/docker/compose/releases/download/v2.23.3/docker-compose-linux-x86_64" \
  -o /usr/local/bin/docker-compose

sudo chmod +x /usr/local/bin/docker-compose

mkdir -p /home/opc/app
chown opc:opc /home/opc/app
