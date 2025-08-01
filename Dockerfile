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

# Ajustar permissões
RUN chmod -R 755 /usr/local/tomcat/webapps/pjecalc

# Expor portas
EXPOSE 9256 9257 9258

# Comando para iniciar o Tomcat
CMD ["catalina.sh", "run"]
