#!/bin/bash
# cloud_init.sh - prepara la VM para correr docker-compose del proyecto "hotel"

set -euo pipefail

log() {
  echo "[cloud-init] $1"
}

log "Actualizando paquetes..."
sudo yum update -y || sudo dnf update -y || true

# -------------------------------------------------------
# Docker
# -------------------------------------------------------
if ! command -v docker >/dev/null 2>&1; then
  log "Instalando Docker..."
  sudo yum install -y docker || sudo dnf install -y docker
  sudo systemctl enable docker
  sudo systemctl start docker
else
  log "Docker ya instalado, asegurando que esté levantado..."
  sudo systemctl enable docker || true
  sudo systemctl start docker || true
fi

# Agregar usuario opc al grupo docker
if id "opc" &>/dev/null; then
  sudo usermod -aG docker opc || true
fi

# -------------------------------------------------------
# docker-compose (binario v2 simple)
# -------------------------------------------------------
if ! command -v docker-compose >/dev/null 2>&1; then
  log "Instalando docker-compose v2..."
  sudo curl -L "https://github.com/docker/compose/releases/download/v2.23.3/docker-compose-linux-x86_64" \
    -o /usr/local/bin/docker-compose
  sudo chmod +x /usr/local/bin/docker-compose
else
  log "docker-compose ya instalado."
fi

# -------------------------------------------------------
# directorio de app
# -------------------------------------------------------
log "Creando directorio /home/opc/app..."
sudo mkdir -p /home/opc/app
sudo chown opc:opc /home/opc/app

# -------------------------------------------------------
# red externa para docker-compose (hotel-net)
# -------------------------------------------------------
if ! sudo docker network ls --format '{{.Name}}' | grep -q '^hotel-net$'; then
  log "Creando red docker 'hotel-net'..."
  sudo docker network create hotel-net || true
else
  log "Red docker 'hotel-net' ya existe."
fi

log "cloud-init completado."
