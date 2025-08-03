FROM tomcat:7.0.94-jre8

# Configurar fuso horário
ENV TZ=America/Sao_Paulo

# Criar diretório para logs de diagnóstico
RUN mkdir -p /usr/local/tomcat/diagnostics

# Script de diagnóstico para executar na inicialização
RUN echo '#!/bin/bash\n\
echo "===== DIAGNÓSTICO PJECALC ====="\n\
echo "Data e hora: $(date)"\n\
echo ""\n\
echo "===== VERIFICANDO DIRETÓRIOS ====="\n\
echo "Listando /usr/local/tomcat/webapps:"\n\
ls -la /usr/local/tomcat/webapps/\n\
echo ""\n\
echo "Verificando diretório pjecalc:"\n\
if [ -d "/usr/local/tomcat/webapps/pjecalc" ]; then\n\
  echo "Diretório /pjecalc EXISTE"\n\
  echo "Conteúdo do diretório:"\n\
  ls -la /usr/local/tomcat/webapps/pjecalc/\n\
  echo "Verificando arquivos principais:"\n\
  if [ -f "/usr/local/tomcat/webapps/pjecalc/index.html" ]; then\n\
    echo "index.html EXISTE"\n\
  else\n\
    echo "index.html NÃO EXISTE"\n\
  fi\n\
  if [ -d "/usr/local/tomcat/webapps/pjecalc/WEB-INF" ]; then\n\
    echo "WEB-INF EXISTE"\n\
    ls -la /usr/local/tomcat/webapps/pjecalc/WEB-INF/\n\
  else\n\
    echo "WEB-INF NÃO EXISTE"\n\
  fi\n\
else\n\
  echo "Diretório /pjecalc NÃO EXISTE"\n\
fi\n\
echo ""\n\
echo "===== VERIFICANDO CONFIGURAÇÃO DO TOMCAT ====="\n\
echo "Porta configurada:"\n\
grep "Connector port" /usr/local/tomcat/conf/server.xml\n\
echo ""\n\
echo "===== VERIFICANDO VARIÁVEIS DE AMBIENTE ====="\n\
echo "CATALINA_OPTS: $CATALINA_OPTS"\n\
echo ""\n\
echo "===== FIM DO DIAGNÓSTICO =====" > /usr/local/tomcat/diagnostics/diagnostic.sh

# Tornar o script executável
RUN chmod +x /usr/local/tomcat/diagnostics/diagnostic.sh

# Remover o webapps padrão do Tomcat
RUN rm -rf /usr/local/tomcat/webapps/*

# Criar diretório para dados do H2
RUN mkdir -p /usr/local/tomcat/.dados

# Criar diretório para a aplicação
RUN mkdir -p /usr/local/tomcat/webapps/pjecalc

# Criar um arquivo index.html de diagnóstico
RUN echo '<!DOCTYPE html>\
<html>\
<head>\
    <title>PJE-Calc Diagnóstico</title>\
    <meta charset="UTF-8">\
</head>\
<body>\
    <h1>PJE-Calc - Página de Diagnóstico</h1>\
    <p>Se você está vendo esta página, o contexto /pjecalc está funcionando corretamente.</p>\
    <p>Esta é uma página de diagnóstico criada pelo Dockerfile.debug.</p>\
</body>\
</html>' > /usr/local/tomcat/webapps/pjecalc/index.html

# Criar um arquivo web.xml básico
RUN mkdir -p /usr/local/tomcat/webapps/pjecalc/WEB-INF
RUN echo '<?xml version="1.0" encoding="UTF-8"?>\
<web-app xmlns="http://java.sun.com/xml/ns/javaee"\
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"\
         xsi:schemaLocation="http://java.sun.com/xml/ns/javaee\
         http://java.sun.com/xml/ns/javaee/web-app_2_5.xsd"\
         version="2.5">\
    <display-name>PJE-Calc Diagnóstico</display-name>\
    <welcome-file-list>\
        <welcome-file>index.html</welcome-file>\
    </welcome-file-list>\
</web-app>' > /usr/local/tomcat/webapps/pjecalc/WEB-INF/web.xml

# Copiar a aplicação PJE-Calc (se existir)
COPY tomcat/webapps/pjecalc /usr/local/tomcat/webapps/pjecalc/

# Ajustar permissões
RUN chmod -R 755 /usr/local/tomcat/webapps/pjecalc/

# Modificar o script de inicialização do Tomcat para executar o diagnóstico
RUN echo '#!/bin/bash\n\
# Executar diagnóstico\n\
/usr/local/tomcat/diagnostics/diagnostic.sh > /usr/local/tomcat/diagnostics/resultado.log 2>&1\n\
\n\
# Iniciar o Tomcat normalmente\n\
exec catalina.sh run' > /usr/local/tomcat/bin/startup-with-diagnostic.sh

# Tornar o script executável
RUN chmod +x /usr/local/tomcat/bin/startup-with-diagnostic.sh

# Configurar variáveis de ambiente do Tomcat
ENV CATALINA_OPTS="-Duser.timezone=America/Sao_Paulo -Dfile.encoding=UTF-8 -Xms512m -Xmx1024m"

# Expor porta padrão do Tomcat
EXPOSE 8080

# Iniciar Tomcat com diagnóstico
CMD ["/usr/local/tomcat/bin/startup-with-diagnostic.sh"]
