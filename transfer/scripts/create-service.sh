#!/bin/bash
# create-service.sh - Criar serviço systemd para o PJE-Calc

# Criar arquivo de serviço
cat > /etc/systemd/system/pjecalc.service << EOF
[Unit]
Description=PJE-Calc Service
After=network.target

[Service]
Type=forking
User=root
ExecStart=/opt/pjecalc/scripts/start-pjecalc.sh
ExecStop=/opt/pjecalc/scripts/stop-pjecalc.sh
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

# Recarregar configuração do systemd
systemctl daemon-reload

# Habilitar serviço para iniciar com o sistema
systemctl enable pjecalc

echo "Serviço systemd criado com sucesso!"
echo "Para iniciar: systemctl start pjecalc"
echo "Para verificar status: systemctl status pjecalc"
