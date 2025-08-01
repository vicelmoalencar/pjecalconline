#!/bin/bash
# start-pjecalc.sh - Script de inicialização do PJE-Calc para Linux

# Definir diretório base
BASE_DIR=$(dirname "$(readlink -f "$0")")/..
cd $BASE_DIR

# Configurações do Java
export JAVA_OPTS="-Duser.timezone=GMT-3 -Dfile.encoding=ISO-8859-1 -Dseguranca.pjecalc.tokenServicos=pW4jZ4g9VM5MCy6FnB5pEfQe -Dseguranca.pjekz.servico.contexto=https://pje.trtXX.jus.br/pje-seguranca -Xms1024m -Xmx2048m"

# Iniciar o Tomcat
$BASE_DIR/tomcat/bin/catalina.sh start

# Aguardar inicialização do Tomcat
sleep 5

echo "PJE-Calc iniciado com sucesso!"
echo "Acesse: http://seu-servidor:9257/pjecalc"
