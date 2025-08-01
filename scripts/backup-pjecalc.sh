#!/bin/bash
# backup-pjecalc.sh - Script para backup do PJE-Calc

# Configurações
BACKUP_DIR="/backup/pjecalc"
DATE=$(date +%Y%m%d-%H%M)
BACKUP_FILE="$BACKUP_DIR/pjecalc-backup-$DATE.tar.gz"

# Criar diretório de backup se não existir
mkdir -p $BACKUP_DIR

# Parar o serviço para garantir consistência
systemctl stop pjecalc || /opt/pjecalc/scripts/stop-pjecalc.sh

# Criar backup
tar -czf $BACKUP_FILE -C /opt pjecalc

# Reiniciar o serviço
systemctl start pjecalc || /opt/pjecalc/scripts/start-pjecalc.sh

# Remover backups antigos (manter últimos 7)
find $BACKUP_DIR -name "pjecalc-backup-*.tar.gz" -type f -mtime +7 -delete

echo "Backup concluído: $BACKUP_FILE"
