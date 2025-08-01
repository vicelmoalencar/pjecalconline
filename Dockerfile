FROM tomcat:7.0.94-jre8

# Configurar fuso horário
ENV TZ=America/Sao_Paulo
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

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
    <title>PJE-Calc Test</title>\
    <meta charset="UTF-8">\
</head>\
<body>\
    <h1>PJE-Calc Test Page</h1>\
    <p>Esta é uma página de teste para verificar se o contexto /pjecalc está funcionando.</p>\
    <p>Timestamp: '$(date)'</p>\
</body>\
</html>' > /usr/local/tomcat/webapps/pjecalc/index.html

# Criar um arquivo web.xml básico para teste
RUN mkdir -p /usr/local/tomcat/webapps/pjecalc/WEB-INF
RUN echo '<?xml version="1.0" encoding="UTF-8"?>\
<web-app xmlns="http://java.sun.com/xml/ns/javaee"\
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"\
         xsi:schemaLocation="http://java.sun.com/xml/ns/javaee\
         http://java.sun.com/xml/ns/javaee/web-app_2_5.xsd"\
         version="2.5">\
    <display-name>PJE-Calc Test</display-name>\
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

# Criar um script de diagnóstico simples
RUN echo '#!/bin/sh\n\
echo "=== DIAGNÓSTICO BÁSICO ==="\n\
echo ""\n\
echo "=== Estrutura de diretórios ==="\n\
find /usr/local/tomcat/webapps -type d\n\
echo ""\n\
echo "=== Arquivos em /pjecalc ==="\n\
find /usr/local/tomcat/webapps/pjecalc -type f\n\
echo ""\n\
echo "=== Conteúdo do web.xml ==="\n\
cat /usr/local/tomcat/webapps/pjecalc/WEB-INF/web.xml\n\
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
