FROM tomcat:7.0.94-jre8

# Configurar fuso horário
ENV TZ=America/Sao_Paulo

# Configurar portas do Tomcat
RUN sed -i 's/port="8080"/port="9257"/g' /usr/local/tomcat/conf/server.xml && \
    sed -i 's/port="8009"/port="9258"/g' /usr/local/tomcat/conf/server.xml

# Criar diretório para dados do H2
RUN mkdir -p /usr/local/tomcat/.dados

# Criar diretório para a aplicação
RUN mkdir -p /usr/local/tomcat/webapps/pjecalc

# Criar um arquivo index.html básico para teste
RUN echo '<!DOCTYPE html>\
<html>\
<head>\
    <title>PJE-Calc</title>\
    <meta charset="UTF-8">\
</head>\
<body>\
    <h1>PJE-Calc</h1>\
    <p>Aplicação PJE-Calc instalada com sucesso!</p>\
    <p>Por favor, acesse <a href="logon.jsf">logon.jsf</a> para entrar no sistema.</p>\
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
    <display-name>PJE-Calc</display-name>\
    <servlet>\
        <servlet-name>Faces Servlet</servlet-name>\
        <servlet-class>javax.faces.webapp.FacesServlet</servlet-class>\
        <load-on-startup>1</load-on-startup>\
    </servlet>\
    <servlet-mapping>\
        <servlet-name>Faces Servlet</servlet-name>\
        <url-pattern>*.jsf</url-pattern>\
    </servlet-mapping>\
    <welcome-file-list>\
        <welcome-file>index.html</welcome-file>\
    </welcome-file-list>\
</web-app>' > /usr/local/tomcat/webapps/pjecalc/WEB-INF/web.xml

# Configurar variáveis de ambiente do Tomcat
ENV CATALINA_OPTS="-Duser.timezone=America/Sao_Paulo -Dfile.encoding=UTF-8 -Xms512m -Xmx1024m"

# Expor portas
EXPOSE 9257 9258

# Iniciar Tomcat
CMD ["catalina.sh", "run"]
