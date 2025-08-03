FROM tomcat:7.0.94-jre8

# Configurar fuso horário
ENV TZ=America/Sao_Paulo

# Remover o webapps padrão do Tomcat
RUN rm -rf /usr/local/tomcat/webapps/*

# Criar diretório para dados do H2
RUN mkdir -p /usr/local/tomcat/.dados

# Criar diretório para a aplicação
RUN mkdir -p /usr/local/tomcat/webapps/pjecalc

# Copiar a aplicação PJE-Calc
COPY tomcat/webapps/pjecalc /usr/local/tomcat/webapps/pjecalc/

# Ajustar permissões
RUN chmod -R 755 /usr/local/tomcat/webapps/pjecalc/

# Configurar variáveis de ambiente do Tomcat
ENV CATALINA_OPTS="-Duser.timezone=America/Sao_Paulo -Dfile.encoding=UTF-8 -Xms512m -Xmx1024m"

# Expor portas (mantendo a porta padrão 8080 que está sendo usada nos logs)
EXPOSE 8080

# Iniciar Tomcat
CMD ["catalina.sh", "run"]
