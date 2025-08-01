#!/bin/bash
# Script para corrigir configurações de datasource no PJE-Calc
# Este script ajusta as propriedades obsoletas do DBCP para DBCP2 no Tomcat

echo "Iniciando correção das configurações de datasource do PJE-Calc..."

# Função para ajustar o arquivo context.xml
fix_context_xml() {
    local context_file=$1
    echo "Processando arquivo: $context_file"
    
    # Backup do arquivo original
    cp "$context_file" "${context_file}.bak"
    echo "Backup criado: ${context_file}.bak"
    
    # Substituir maxActive por maxTotal
    sed -i 's/maxActive=/maxTotal=/g' "$context_file"
    
    # Substituir maxWait por maxWaitMillis
    sed -i 's/maxWait=/maxWaitMillis=/g' "$context_file"
    
    # Outras possíveis substituições de propriedades obsoletas
    sed -i 's/removeAbandoned=/removeAbandonedOnBorrow=/g' "$context_file"
    sed -i 's/removeAbandonedTimeout=/removeAbandonedTimeout=/g' "$context_file"
    
    echo "Arquivo $context_file atualizado com sucesso!"
}

# Função para ajustar arquivos XML em geral (para outros arquivos de configuração)
fix_xml_files() {
    local dir=$1
    echo "Procurando arquivos XML em: $dir"
    
    # Encontrar todos os arquivos XML no diretório
    find "$dir" -name "*.xml" -type f | while read -r xml_file; do
        # Verificar se o arquivo contém configurações de datasource
        if grep -q "javax.sql.DataSource" "$xml_file"; then
            echo "Encontrado arquivo de configuração de datasource: $xml_file"
            fix_context_xml "$xml_file"
        fi
    done
}

# Função para ajustar permissões
fix_permissions() {
    local dir=$1
    echo "Ajustando permissões em: $dir"
    
    # Garantir que os diretórios tenham permissões adequadas
    find "$dir" -type d -exec chmod 755 {} \;
    
    # Garantir que os arquivos tenham permissões adequadas
    find "$dir" -type f -exec chmod 644 {} \;
    
    # Garantir que os scripts tenham permissão de execução
    find "$dir" -name "*.sh" -exec chmod +x {} \;
    
    echo "Permissões ajustadas com sucesso!"
}

# Verificar se estamos em um contêiner Docker
if [ -f /.dockerenv ]; then
    echo "Executando dentro de um contêiner Docker"
    TOMCAT_HOME="/usr/local/tomcat"
    APP_DIR="$TOMCAT_HOME/webapps/pjecalc"
else
    echo "Executando fora de um contêiner Docker"
    # Ajustar para o diretório correto se estiver executando fora do contêiner
    TOMCAT_HOME="/opt/tomcat"
    APP_DIR="$TOMCAT_HOME/webapps/pjecalc"
    
    # Verificar se o diretório existe
    if [ ! -d "$TOMCAT_HOME" ]; then
        echo "Diretório Tomcat não encontrado em $TOMCAT_HOME"
        echo "Por favor, especifique o caminho correto para o Tomcat:"
        read -r TOMCAT_HOME
        APP_DIR="$TOMCAT_HOME/webapps/pjecalc"
    fi
fi

# Verificar se o diretório da aplicação existe
if [ ! -d "$APP_DIR" ]; then
    echo "Diretório da aplicação não encontrado em $APP_DIR"
    echo "Por favor, especifique o caminho correto para a aplicação PJE-Calc:"
    read -r APP_DIR
fi

echo "Diretório Tomcat: $TOMCAT_HOME"
echo "Diretório da aplicação: $APP_DIR"

# Corrigir arquivos de configuração do Tomcat
echo "Corrigindo arquivos de configuração do Tomcat..."
if [ -f "$TOMCAT_HOME/conf/context.xml" ]; then
    fix_context_xml "$TOMCAT_HOME/conf/context.xml"
fi

if [ -f "$TOMCAT_HOME/conf/server.xml" ]; then
    fix_context_xml "$TOMCAT_HOME/conf/server.xml"
fi

# Corrigir arquivos de configuração da aplicação
echo "Corrigindo arquivos de configuração da aplicação..."
if [ -d "$APP_DIR/META-INF" ]; then
    if [ -f "$APP_DIR/META-INF/context.xml" ]; then
        fix_context_xml "$APP_DIR/META-INF/context.xml"
    fi
    fix_xml_files "$APP_DIR/META-INF"
fi

if [ -d "$APP_DIR/WEB-INF" ]; then
    fix_xml_files "$APP_DIR/WEB-INF"
fi

# Ajustar permissões
echo "Ajustando permissões..."
fix_permissions "$APP_DIR"

echo "Processo de correção concluído!"
echo "Por favor, reinicie o Tomcat para aplicar as alterações."

# Instruções para reiniciar o Tomcat
echo ""
echo "Para reiniciar o Tomcat no contêiner Docker, execute:"
echo "docker restart <container_id>"
echo ""
echo "Ou no EasyPanel, use o botão de reiniciar o contêiner."
