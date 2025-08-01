FROM tomcat:7.0.94-jre8

# Configurar fuso horário
ENV TZ=America/Sao_Paulo
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Configurar Tomcat
COPY tomcat/conf/server.xml /usr/local/tomcat/conf/
COPY tomcat/conf/context.xml /usr/local/tomcat/conf/
COPY tomcat/conf/logging.properties /usr/local/tomcat/conf/

# Copiar aplicação
COPY tomcat/webapps/pjecalc /usr/local/tomcat/webapps/pjecalc/

# Criar diretório para dados do H2
RUN mkdir -p /usr/local/tomcat/webapps/pjecalc/.dados

# Criar script de diagnóstico
RUN echo '#!/bin/bash\n\
echo "=== DIAGNÓSTICO DE ERRO 404 ==="\n\
echo ""\n\
echo "=== Listando arquivos em /usr/local/tomcat/webapps/pjecalc/ ==="\n\
find /usr/local/tomcat/webapps/pjecalc -type f -name "*.jsf" -o -name "*.xhtml" | sort\n\
echo ""\n\
echo "=== Verificando web.xml ==="\n\
cat /usr/local/tomcat/webapps/pjecalc/WEB-INF/web.xml | grep -A 10 "faces-servlet"\n\
echo ""\n\
echo "=== Verificando logs de acesso ==="\n\
touch /usr/local/tomcat/logs/localhost_access_log.txt\n\
tail -100 /usr/local/tomcat/logs/localhost_access_log.txt\n\
echo ""\n\
echo "=== Verificando permissões de arquivos ==="\n\
ls -la /usr/local/tomcat/webapps/pjecalc/\n\
echo ""\n\
echo "=== Verificando estrutura de diretórios ==="\n\
find /usr/local/tomcat/webapps/pjecalc -type d | sort\n\
echo ""\n\
echo "=== Iniciando Tomcat ==="\n\
catalina.sh run\n\
' > /usr/local/tomcat/bin/diagnostic.sh

RUN chmod +x /usr/local/tomcat/bin/diagnostic.sh

# Configurar variáveis de ambiente do Tomcat
ENV CATALINA_OPTS="-Duser.timezone=America/Sao_Paulo -Dfile.encoding=UTF-8 -Xms512m -Xmx1024m"

# Expor portas
EXPOSE 9257 9258

# Iniciar com script de diagnóstico
CMD ["/usr/local/tomcat/bin/diagnostic.sh"]
