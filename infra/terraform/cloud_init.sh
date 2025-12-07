#!/bin/bash
# ============================================
# cloud_init.sh — Configuración inicial de VM
# Para servidor de despliegue Docker
# ============================================

LOG_FILE="/var/log/hotel-init.log"
echo "==== INICIO cloud_init.sh $(date) ====" | tee -a $LOG_FILE

# --------------------------------------------
# FUNCIONES DE APOYO
# --------------------------------------------

retry() {
  local retries=$1
  shift
  local count=0

  until "$@"; do
    exit_code=$?
    count=$((count + 1))
    if [ $count -lt $retries ]; then
      echo "Intento $count falló. Reintentando..." | tee -a $LOG_FILE
      sleep 5
    else
      echo "Comando falló después de $retries intentos." | tee -a $LOG_FILE
      return $exit_code
    fi
  done

  return 0
}

ensure_service_running() {
  local service=$1
  echo "Verificando servicio $service..." | tee -a $LOG_FILE

  if ! systemctl is-active --quiet "$service"; then
    echo "Servicio $service no está activo. Intentando iniciar..." | tee -a $LOG_FILE
    systemctl start "$service"
  fi

  systemctl enable "$service"
}

# --------------------------------------------
# ACTUALIZAR SISTEMA
# --------------------------------------------

echo "[1/5] Actualizando sistema..." | tee -a $LOG_FILE
retry 3 sudo yum update -y

# --------------------------------------------
# INSTALAR DOCKER
# --------------------------------------------

if ! command -v docker >/dev/null 2>&1; then
  echo "[2/5] Instalando Docker..." | tee -a $LOG_FILE
  retry 3 sudo yum install -y docker
else
  echo "Docker ya está instalado. Continuando..." | tee -a $LOG_FILE
fi

ensure_service_running docker

# Añadir usuario opc al grupo docker (evita usar sudo)
usermod -aG docker opc

# --------------------------------------------
# INSTALAR DOCKER COMPOSE V2
# --------------------------------------------

if ! command -v docker-compose >/dev/null 2>&1; then
  echo "[3/5] Instalando Docker Compose..." | tee -a $LOG_FILE
  retry 3 sudo curl -L \
    "https://github.com/docker/compose/releases/download/v2.23.3/docker-compose-linux-x86_64" \
    -o /usr/local/bin/docker-compose

  sudo chmod +x /usr/local/bin/docker-compose
else
  echo "Docker Compose ya instalado." | tee -a $LOG_FILE
fi

# --------------------------------------------
# PREPARAR DIRECTORIO DE LA APP
# --------------------------------------------

echo "[4/5] Preparando estructura de directorios..." | tee -a $LOG_FILE

mkdir -p /home/opc/app

# Asegurar permisos correctos
chown -R opc:opc /home/opc/app

# --------------------------------------------
# CONFIGURAR NETWORK PARA CONTENEDORES (OPCIONAL)
# --------------------------------------------

echo "[5/5] Creando red Docker para la app (si no existe)..." | tee -a $LOG_FILE
if ! docker network ls | grep -q "hotel-net"; then
  docker network create hotel-net
  echo "Red hotel-net creada." | tee -a $LOG_FILE
else
  echo "Red hotel-net ya existía." | tee -a $LOG_FILE
fi

echo "==== FIN cloud_init.sh $(date) ====" | tee -a $LOG_FILE
