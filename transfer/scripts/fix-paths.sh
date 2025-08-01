#!/bin/bash
# fix-paths.sh - Script para ajustar caminhos de arquivo para o formato Linux

# Diretório base
BASE_DIR="/opt/pjecalc"

# Arquivos de configuração que podem conter caminhos Windows
CONFIG_FILES=(
  "$BASE_DIR/tomcat/conf/server.xml"
  "$BASE_DIR/tomcat/conf/context.xml"
  "$BASE_DIR/tomcat/webapps/pjecalc/WEB-INF/web.xml"
)

# Substituir backslashes por forward slashes
for file in "${CONFIG_FILES[@]}"; do
  if [ -f "$file" ]; then
    echo "Ajustando caminhos em $file..."
    sed -i 's/\\/\//g' "$file"
  fi
done

# Ajustar referências a unidades do Windows (C:, D:, etc.)
for file in "${CONFIG_FILES[@]}"; do
  if [ -f "$file" ]; then
    echo "Removendo referências a unidades do Windows em $file..."
    sed -i 's/[A-Z]:\//\//g' "$file"
  fi
done

echo "Ajustes de caminhos concluídos!"
