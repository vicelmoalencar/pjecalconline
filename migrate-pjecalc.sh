#!/bin/bash
# migrate-pjecalc.sh - Script principal para migração do PJE-Calc para VPS com EasyPanel

# Definir cores para melhor visualização
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Função para exibir mensagens
print_message() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[AVISO]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERRO]${NC} $1"
}

# Verificar se está sendo executado como root
if [ "$EUID" -ne 0 ]; then
    print_error "Este script precisa ser executado como root (sudo)."
    exit 1
fi

# Definir diretório base
BASE_DIR=$(dirname "$(readlink -f "$0")")
INSTALL_DIR="/opt/pjecalc"
EASYPANEL_DIR="/opt/easypanel/projects/pjecalc"

print_message "Iniciando migração do PJE-Calc para VPS com EasyPanel..."
print_message "Diretório base: $BASE_DIR"

# Passo 1: Verificar pré-requisitos
print_message "Verificando pré-requisitos..."

# Verificar se o Docker está instalado
if ! command -v docker &> /dev/null; then
    print_warning "Docker não encontrado. Instalando..."
    apt update
    apt install -y docker.io
    systemctl enable --now docker
else
    print_message "Docker já está instalado."
fi

# Verificar se o Docker Compose está instalado
if ! command -v docker-compose &> /dev/null; then
    print_warning "Docker Compose não encontrado. Instalando..."
    apt install -y docker-compose
else
    print_message "Docker Compose já está instalado."
fi

# Verificar se o EasyPanel está instalado
if [ ! -d "/opt/easypanel" ]; then
    print_warning "EasyPanel não encontrado. Instalando..."
    curl -sSL https://get.easypanel.io | sh
    print_message "EasyPanel instalado. Por favor, configure-o acessando https://seu-ip"
    print_warning "Após configurar o EasyPanel, execute este script novamente."
    exit 0
else
    print_message "EasyPanel já está instalado."
fi

# Passo 2: Criar diretórios necessários
print_message "Criando diretórios necessários..."
mkdir -p $INSTALL_DIR
mkdir -p $EASYPANEL_DIR
mkdir -p /backup/pjecalc
mkdir -p /var/log/pjecalc

# Passo 3: Copiar arquivos
print_message "Copiando arquivos para o diretório de instalação..."
cp -r $BASE_DIR/bin $INSTALL_DIR/ || print_warning "Diretório bin não encontrado."
cp -r $BASE_DIR/tomcat $INSTALL_DIR/ || print_warning "Diretório tomcat não encontrado."
cp -r $BASE_DIR/.dados $INSTALL_DIR/ || print_warning "Diretório .dados não encontrado."
cp -r $BASE_DIR/scripts $INSTALL_DIR/
cp $BASE_DIR/docker-compose.yml $EASYPANEL_DIR/

# Passo 4: Ajustar permissões
print_message "Ajustando permissões..."
chmod +x $INSTALL_DIR/scripts/*.sh
chmod +x $INSTALL_DIR/tomcat/bin/*.sh 2>/dev/null || print_warning "Não foi possível ajustar permissões dos scripts do Tomcat."
chmod -R 755 $INSTALL_DIR/tomcat/webapps 2>/dev/null || print_warning "Não foi possível ajustar permissões dos webapps."

# Passo 5: Criar links simbólicos para os scripts
print_message "Criando links simbólicos..."
ln -sf $INSTALL_DIR/scripts/start-pjecalc.sh /usr/local/bin/start-pjecalc
ln -sf $INSTALL_DIR/scripts/stop-pjecalc.sh /usr/local/bin/stop-pjecalc

# Passo 6: Ajustar caminhos de arquivo
print_message "Ajustando caminhos de arquivo para o formato Linux..."
$INSTALL_DIR/scripts/fix-paths.sh

# Passo 7: Configurar serviço systemd
print_message "Configurando serviço systemd..."
$INSTALL_DIR/scripts/create-service.sh

# Passo 8: Configurar logs
print_message "Configurando sistema de logs..."
$INSTALL_DIR/scripts/setup-logging.sh

# Passo 9: Configurar backup automático
print_message "Configurando backup automático..."
cp $INSTALL_DIR/scripts/backup-pjecalc.sh /etc/cron.daily/
chmod +x /etc/cron.daily/backup-pjecalc.sh

# Passo 10: Configurar firewall
print_message "Configurando firewall..."
if command -v ufw &> /dev/null; then
    ufw allow 9256/tcp
    ufw allow 9257/tcp
    ufw allow 9258/tcp
    print_message "Portas 9256, 9257 e 9258 liberadas no firewall."
else
    print_warning "UFW não encontrado. Por favor, configure manualmente o firewall para permitir as portas 9256, 9257 e 9258."
fi

# Passo 11: Iniciar o serviço
print_message "Iniciando o serviço PJE-Calc..."
systemctl start pjecalc || print_warning "Não foi possível iniciar o serviço. Tente iniciar manualmente com 'start-pjecalc'."

print_message "Migração concluída com sucesso!"
print_message "Acesse o PJE-Calc em: http://seu-servidor:9257/pjecalc"
print_message "Para mais informações, consulte o arquivo README.md"
