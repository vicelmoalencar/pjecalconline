#!/bin/bash

# Script de inicialização personalizado para diagnóstico do PJE-Calc

echo "=== INICIANDO DIAGNÓSTICO DO PJE-CALC ==="

# Verificar estrutura de diretórios
echo "=== ESTRUTURA DE DIRETÓRIOS ==="
echo "Verificando diretório webapps/pjecalc:"
ls -la /usr/local/tomcat/webapps/pjecalc
echo ""

echo "Verificando diretório WEB-INF:"
if [ -d "/usr/local/tomcat/webapps/pjecalc/WEB-INF" ]; then
    ls -la /usr/local/tomcat/webapps/pjecalc/WEB-INF
else
    echo "Diretório WEB-INF não encontrado!"
fi
echo ""

echo "Verificando diretório WEB-INF/lib:"
if [ -d "/usr/local/tomcat/webapps/pjecalc/WEB-INF/lib" ]; then
    ls -la /usr/local/tomcat/webapps/pjecalc/WEB-INF/lib
else
    echo "Diretório WEB-INF/lib não encontrado!"
fi
echo ""

echo "Verificando diretório META-INF:"
if [ -d "/usr/local/tomcat/webapps/pjecalc/META-INF" ]; then
    ls -la /usr/local/tomcat/webapps/pjecalc/META-INF
else
    echo "Diretório META-INF não encontrado!"
fi
echo ""

# Verificar arquivos de configuração
echo "=== ARQUIVOS DE CONFIGURAÇÃO ==="
echo "Verificando context.xml:"
if [ -f "/usr/local/tomcat/webapps/pjecalc/META-INF/context.xml" ]; then
    cat /usr/local/tomcat/webapps/pjecalc/META-INF/context.xml
else
    echo "Arquivo context.xml não encontrado!"
fi
echo ""

echo "Verificando web.xml:"
if [ -f "/usr/local/tomcat/webapps/pjecalc/WEB-INF/web.xml" ]; then
    cat /usr/local/tomcat/webapps/pjecalc/WEB-INF/web.xml
else
    echo "Arquivo web.xml não encontrado!"
fi
echo ""

# Iniciar o Tomcat com logs detalhados
echo "=== INICIANDO TOMCAT ==="
echo "Iniciando Tomcat com logs detalhados..."
catalina.sh run
