#!/bin/bash

# Colores para los mensajes
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}Iniciando instalación del Kintaro Controller...${NC}"

# Verificar si es root
if [[ $EUID -ne 0 ]]; then
    echo -e "${RED}Este script debe ser ejecutado como root${NC}"
    echo "Intenta: sudo $0"
    exit 1
fi

# Verificar si es una Raspberry Pi
if ! grep -q "Raspberry Pi" /proc/cpuinfo; then
    echo -e "${RED}Este script solo funciona en Raspberry Pi${NC}"
    exit 1
fi

# Montar sistema en modo escritura
echo "Montando sistema en modo escritura..."
mount -o remount,rw /

# Crear directorio temporal
TMP_DIR=$(mktemp -d)
cd $TMP_DIR

# Descargar archivos
echo "Descargando archivos..."
curl -sSL https://raw.githubusercontent.com/eduard0bet/kintaro-recalbox/refs/heads/release/Kintaro/kintaro.py -o kintaro.py
curl -sSL https://raw.githubusercontent.com/eduard0bet/kintaro-recalbox/refs/heads/release/S100kintaro.sh -o S100kintaro.sh

if [ ! -f kintaro.py ] || [ ! -f S100kintaro.sh ]; then
    echo -e "${RED}Error al descargar los archivos${NC}"
    exit 1
fi

# Crear estructura de directorios
echo "Creando directorios..."
mkdir -p /opt/Kintaro

# Copiar archivos
echo "Copiando archivos..."
cp -f kintaro.py /opt/Kintaro/
cp -f S100kintaro.sh /etc/init.d/

# Establecer permisos
echo "Configurando permisos..."
chmod 755 /opt/Kintaro/kintaro.py
chmod 755 /etc/init.d/S100kintaro.sh

# Limpiar directorio temporal
echo "Limpiando archivos temporales..."
cd /
rm -rf $TMP_DIR

# Verificar la instalación
if [ -f /opt/Kintaro/kintaro.py ] && [ -f /etc/init.d/S100kintaro.sh ]; then
    echo -e "${GREEN}Instalación completada exitosamente${NC}"
    echo -e "${GREEN}Reiniciando el sistema en 5 segundos...${NC}"
    sleep 5
    reboot
else
    echo -e "${RED}Error en la instalación${NC}"
    exit 1
fi