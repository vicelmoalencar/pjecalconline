#!/bin/bash
# install-pjecalc.sh - Script para instalar o PJE-Calc na VPS

# Definir diretório de instalação
INSTALL_DIR="/opt/pjecalc"
EASYPANEL_DIR="/opt/easypanel/projects/pjecalc"

# Criar diretórios necessários
mkdir -p $INSTALL_DIR
mkdir -p $EASYPANEL_DIR

# Copiar arquivos para o diretório de instalação
echo "Copiando arquivos..."
cp -r bin $INSTALL_DIR/
cp -r tomcat $INSTALL_DIR/
cp -r .dados $INSTALL_DIR/
cp -r scripts $INSTALL_DIR/

# Copiar docker-compose.yml para o diretório do EasyPanel
cp docker-compose.yml $EASYPANEL_DIR/

# Ajustar permissões
echo "Ajustando permissões..."
chmod +x $INSTALL_DIR/scripts/*.sh
chmod +x $INSTALL_DIR/tomcat/bin/*.sh
chmod -R 755 $INSTALL_DIR/tomcat/webapps

# Criar links simbólicos para os scripts
ln -sf $INSTALL_DIR/scripts/start-pjecalc.sh /usr/local/bin/start-pjecalc
ln -sf $INSTALL_DIR/scripts/stop-pjecalc.sh /usr/local/bin/stop-pjecalc

echo "Instalação concluída!"
echo "Para iniciar o PJE-Calc, use o EasyPanel ou execute: start-pjecalc"
