FROM tomcat:7-jre8

# Configuração de variáveis de ambiente
ENV JAVA_OPTS="-Duser.timezone=America/Sao_Paulo -Dfile.encoding=UTF-8 -Xms512m -Xmx1024m"
ENV CATALINA_OPTS="-Dorg.apache.catalina.connector.RECYCLE_FACADES=false"

# Configurar portas do Tomcat
RUN sed -i 's/port="8080"/port="9257"/g' /usr/local/tomcat/conf/server.xml && \
    sed -i 's/port="8005"/port="9256"/g' /usr/local/tomcat/conf/server.xml && \
    sed -i 's/port="8009"/port="9258"/g' /usr/local/tomcat/conf/server.xml

# Criar diretório para aplicação e banco de dados
RUN mkdir -p /usr/local/tomcat/webapps/pjecalc && \
    mkdir -p /usr/local/tomcat/.dados && \
    chmod -R 777 /usr/local/tomcat/.dados

# Copiar arquivos da aplicação
COPY ./transfer/tomcat/webapps/pjecalc /usr/local/tomcat/webapps/pjecalc/

# Corrigir configurações de datasource no context.xml e outros arquivos XML
RUN find /usr/local/tomcat -name "*.xml" -type f -exec sed -i 's/maxActive=/maxTotal=/g' {} \; && \
    find /usr/local/tomcat -name "*.xml" -type f -exec sed -i 's/maxWait=/maxWaitMillis=/g' {} \; && \
    find /usr/local/tomcat -name "*.xml" -type f -exec sed -i 's/removeAbandoned=/removeAbandonedOnBorrow=/g' {} \; && \
    find /usr/local/tomcat -name "*.xml" -type f -exec sed -i 's/removeAbandonedTimeout=/removeAbandonedTimeout=/g' {} \;

# Verificar arquivos específicos de configuração do datasource
RUN if [ -f /usr/local/tomcat/webapps/pjecalc/META-INF/context.xml ]; then \
        sed -i 's|jdbc:h2:.dados/pjecalc|jdbc:h2:/usr/local/tomcat/.dados/pjecalc|g' /usr/local/tomcat/webapps/pjecalc/META-INF/context.xml; \
    fi

# Ajustar permissões
RUN chmod -R 755 /usr/local/tomcat/webapps/pjecalc

# Expor portas
EXPOSE 9256 9257 9258

# Comando para iniciar o Tomcat
CMD ["catalina.sh", "run"]
