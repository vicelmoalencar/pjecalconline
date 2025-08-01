#!/bin/bash
# setup-logging.sh - Configurar logs para o PJE-Calc

# Diretório de logs
LOG_DIR="/var/log/pjecalc"

# Criar diretório de logs
mkdir -p $LOG_DIR

# Ajustar permissões
chmod 755 $LOG_DIR

# Configurar rotação de logs
cat > /etc/logrotate.d/pjecalc << EOF
$LOG_DIR/*.log {
    daily
    missingok
    rotate 14
    compress
    delaycompress
    notifempty
    create 0644 root root
}
EOF

# Criar link simbólico para logs do Tomcat
ln -sf /opt/pjecalc/tomcat/logs/* $LOG_DIR/

echo "Configuração de logs concluída!"
