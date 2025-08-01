FROM tomcat:8-jre8

# Configuração de variáveis de ambiente
ENV JAVA_OPTS="-Duser.timezone=America/Sao_Paulo -Dfile.encoding=UTF-8 -Xms512m -Xmx1024m -XX:PermSize=256m -XX:MaxPermSize=512m"
ENV CATALINA_OPTS="-Dorg.apache.catalina.connector.RECYCLE_FACADES=false"

# Configurar portas do Tomcat
RUN sed -i 's/port="8080"/port="9257"/g' /usr/local/tomcat/conf/server.xml && \
    sed -i 's/port="8005"/port="9256"/g' /usr/local/tomcat/conf/server.xml && \
    sed -i 's/port="8009"/port="9258"/g' /usr/local/tomcat/conf/server.xml

# Criar diretório para aplicação
RUN mkdir -p /usr/local/tomcat/webapps/pjecalc

# Copiar arquivos da aplicação (apenas os diretórios que existem)
COPY ./transfer/tomcat/webapps/pjecalc /usr/local/tomcat/webapps/pjecalc/

# Verificar se o diretório conf existe antes de copiar
RUN mkdir -p /usr/local/tomcat/conf

# Corrigir configurações de datasource no context.xml e outros arquivos XML
RUN find /usr/local/tomcat -name "*.xml" -type f -exec sed -i 's/maxActive=/maxTotal=/g' {} \; && \
    find /usr/local/tomcat -name "*.xml" -type f -exec sed -i 's/maxWait=/maxWaitMillis=/g' {} \; && \
    find /usr/local/tomcat -name "*.xml" -type f -exec sed -i 's/removeAbandoned=/removeAbandonedOnBorrow=/g' {} \; && \
    find /usr/local/tomcat -name "*.xml" -type f -exec sed -i 's/removeAbandonedTimeout=/removeAbandonedTimeout=/g' {} \;

# Verificar arquivos específicos de configuração do datasource
RUN if [ -f /usr/local/tomcat/conf/context.xml ]; then \
        sed -i 's/maxActive=/maxTotal=/g' /usr/local/tomcat/conf/context.xml && \
        sed -i 's/maxWait=/maxWaitMillis=/g' /usr/local/tomcat/conf/context.xml; \
    fi && \
    if [ -f /usr/local/tomcat/webapps/pjecalc/META-INF/context.xml ]; then \
        sed -i 's/maxActive=/maxTotal=/g' /usr/local/tomcat/webapps/pjecalc/META-INF/context.xml && \
        sed -i 's/maxWait=/maxWaitMillis=/g' /usr/local/tomcat/webapps/pjecalc/META-INF/context.xml; \
    fi

# Habilitar logs detalhados do Tomcat
RUN sed -i 's/\.level = INFO/\.level = FINE/g' /usr/local/tomcat/conf/logging.properties && \
    sed -i 's/org\.apache\.catalina\.level = INFO/org\.apache\.catalina\.level = FINE/g' /usr/local/tomcat/conf/logging.properties && \
    sed -i 's/org\.apache\.jasper\.level = INFO/org\.apache\.jasper\.level = FINE/g' /usr/local/tomcat/conf/logging.properties

# Verificar estrutura da aplicação e criar diretórios necessários
RUN mkdir -p /usr/local/tomcat/webapps/pjecalc/WEB-INF/lib && \
    mkdir -p /usr/local/tomcat/webapps/pjecalc/WEB-INF/classes && \
    mkdir -p /usr/local/tomcat/webapps/pjecalc/META-INF

# Verificar se há arquivos de configuração específicos e criar se necessário
RUN if [ ! -f /usr/local/tomcat/webapps/pjecalc/META-INF/context.xml ]; then \
        echo '<?xml version="1.0" encoding="UTF-8"?><Context path="/pjecalc"></Context>' > /usr/local/tomcat/webapps/pjecalc/META-INF/context.xml; \
    fi

# Verificar se há arquivos web.xml e criar um básico se necessário
RUN if [ ! -f /usr/local/tomcat/webapps/pjecalc/WEB-INF/web.xml ]; then \
        echo '<?xml version="1.0" encoding="UTF-8"?><web-app xmlns="http://java.sun.com/xml/ns/javaee" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://java.sun.com/xml/ns/javaee http://java.sun.com/xml/ns/javaee/web-app_2_5.xsd" version="2.5"><display-name>PJE-Calc</display-name></web-app>' > /usr/local/tomcat/webapps/pjecalc/WEB-INF/web.xml; \
    fi

# Criar um arquivo index.html básico para teste
RUN echo '<html><head><title>PJE-Calc</title></head><body><h1>PJE-Calc</h1><p>Aplicação em manutenção. Por favor, tente novamente mais tarde.</p></body></html>' > /usr/local/tomcat/webapps/pjecalc/index.html

# Ajustar permissões
RUN chmod -R 755 /usr/local/tomcat/webapps/pjecalc

# Expor portas
EXPOSE 9256 9257 9258

# Script de inicialização personalizado para exibir informações de diagnóstico
COPY ./startup.sh /usr/local/tomcat/bin/
RUN chmod +x /usr/local/tomcat/bin/startup.sh

# Comando para iniciar o Tomcat
CMD ["/usr/local/tomcat/bin/startup.sh"]
