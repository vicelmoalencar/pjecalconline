#!/bin/bash
# stop-pjecalc.sh - Script para parar o PJE-Calc

# Definir diretório base
BASE_DIR=$(dirname "$(readlink -f "$0")")/..

# Parar o Tomcat
$BASE_DIR/tomcat/bin/catalina.sh stop

echo "PJE-Calc foi encerrado."
