# Documentação do PJE-Calc na VPS

## Informações gerais

- **Aplicação**: PJE-Calc versão 2.13.2
- **Servidor**: VPS com EasyPanel
- **URL de acesso**: http://seu-servidor:9257/pjecalc

## Comandos básicos

- **Iniciar o sistema**: `start-pjecalc` ou via EasyPanel
- **Parar o sistema**: `stop-pjecalc` ou via EasyPanel
- **Verificar status**: `systemctl status pjecalc` (se configurado como serviço)

## Logs e monitoramento

- **Logs do sistema**: `/var/log/pjecalc/`
- **Logs do Tomcat**: `/opt/pjecalc/tomcat/logs/`

## Backup e restauração

- **Backups automáticos**: Armazenados em `/backup/pjecalc/`
- **Restaurar backup**: `tar -xzf arquivo-backup.tar.gz -C /`

## Contato para suporte

- Email: seu-email@exemplo.com
- Telefone: (XX) XXXX-XXXX
