FROM tomcat:7.0.94-jre8

# Configurar fuso horário
ENV TZ=America/Sao_Paulo

# Configurar portas do Tomcat
RUN sed -i 's/port="8080"/port="9257"/g' /usr/local/tomcat/conf/server.xml && \
    sed -i 's/port="8009"/port="9258"/g' /usr/local/tomcat/conf/server.xml

# Criar diretório para dados do H2
RUN mkdir -p /usr/local/tomcat/.dados

# Remover o webapps padrão do Tomcat
RUN rm -rf /usr/local/tomcat/webapps/*

# Copiar configurações do Tomcat
COPY tomcat/conf/server.xml /usr/local/tomcat/conf/
COPY tomcat/conf/context.xml /usr/local/tomcat/conf/
COPY tomcat/conf/logging.properties /usr/local/tomcat/conf/

# Copiar a aplicação PJE-Calc
COPY tomcat/webapps/pjecalc /usr/local/tomcat/webapps/pjecalc/

# Ajustar permissões
RUN chmod -R 755 /usr/local/tomcat/webapps/pjecalc/

# Configurar variáveis de ambiente do Tomcat
ENV CATALINA_OPTS="-Duser.timezone=America/Sao_Paulo -Dfile.encoding=UTF-8 -Xms512m -Xmx1024m"

# Expor portas
EXPOSE 9257 9258

# Iniciar Tomcat
CMD ["catalina.sh", "run"]
