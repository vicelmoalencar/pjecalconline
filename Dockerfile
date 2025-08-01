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

# Copiar arquivos da aplicação
COPY ./transfer/tomcat/webapps/pjecalc /usr/local/tomcat/webapps/pjecalc/
COPY ./transfer/tomcat/conf/ /usr/local/tomcat/conf/
COPY ./transfer/tomcat/lib/ /usr/local/tomcat/lib/

# Ajustar permissões
RUN chmod -R 755 /usr/local/tomcat/webapps/pjecalc

# Expor portas
EXPOSE 9256 9257 9258

# Comando para iniciar o Tomcat
CMD ["catalina.sh", "run"]
