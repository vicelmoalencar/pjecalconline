FROM tomcat:7.0.94-jre8

# Configurar fuso horário
ENV TZ=America/Sao_Paulo
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Instalar ferramentas de diagnóstico
RUN apt-get update && apt-get install -y \
    procps \
    net-tools \
    curl \
    vim \
    tree \
    && rm -rf /var/lib/apt/lists/*

# Configurar Tomcat
COPY tomcat/conf/server.xml /usr/local/tomcat/conf/
COPY tomcat/conf/context.xml /usr/local/tomcat/conf/
COPY tomcat/conf/logging.properties /usr/local/tomcat/conf/

# Copiar aplicação
COPY tomcat/webapps/pjecalc /usr/local/tomcat/webapps/pjecalc/

# Criar diretório para dados do H2
RUN mkdir -p /usr/local/tomcat/webapps/pjecalc/.dados

# Corrigir permissões (importante para Linux)
RUN chmod -R 755 /usr/local/tomcat/webapps/pjecalc/
RUN chown -R root:root /usr/local/tomcat/webapps/pjecalc/

# Criar script de diagnóstico avançado
RUN echo '#!/bin/bash\n\
echo "=== DIAGNÓSTICO AVANÇADO DE ERRO 404 ==="\n\
echo ""\n\
echo "=== Verificando versão do Tomcat e Java ==="\n\
java -version\n\
echo "Tomcat version: $(cat /usr/local/tomcat/RELEASE-NOTES | head -n 1)"\n\
echo ""\n\
echo "=== Estrutura completa do diretório webapps/pjecalc ==="\n\
find /usr/local/tomcat/webapps/pjecalc -type f | sort\n\
echo ""\n\
echo "=== Verificando arquivos principais ==="\n\
echo "index.html:"\n\
cat /usr/local/tomcat/webapps/pjecalc/index.html\n\
echo ""\n\
echo "web.xml (mapeamentos):"\n\
grep -A 10 "servlet-mapping" /usr/local/tomcat/webapps/pjecalc/WEB-INF/web.xml\n\
echo ""\n\
echo "=== Verificando arquivos JSF/XHTML ==="\n\
echo "Arquivos .jsf (não devem existir fisicamente):"\n\
find /usr/local/tomcat/webapps/pjecalc -name "*.jsf" | sort\n\
echo ""\n\
echo "Arquivos .xhtml:"\n\
find /usr/local/tomcat/webapps/pjecalc -name "*.xhtml" | sort\n\
echo ""\n\
echo "=== Verificando permissões de arquivos ==="\n\
ls -la /usr/local/tomcat/webapps/pjecalc/\n\
ls -la /usr/local/tomcat/webapps/pjecalc/pages/\n\
echo ""\n\
echo "=== Verificando conteúdo de principal.xhtml ==="\n\
if [ -f /usr/local/tomcat/webapps/pjecalc/pages/principal.xhtml ]; then\n\
  head -n 10 /usr/local/tomcat/webapps/pjecalc/pages/principal.xhtml\n\
else\n\
  echo "ERRO: Arquivo principal.xhtml não encontrado!"\n\
  echo "Procurando por arquivos similares:"\n\
  find /usr/local/tomcat/webapps/pjecalc -name "*principal*" | sort\n\
fi\n\
echo ""\n\
echo "=== Verificando configuração do Faces Servlet ==="\n\
grep -A 20 "Faces Servlet" /usr/local/tomcat/webapps/pjecalc/WEB-INF/web.xml\n\
echo ""\n\
echo "=== Verificando logs do Tomcat ==="\n\
touch /usr/local/tomcat/logs/catalina.out\n\
echo "Últimas linhas do catalina.out:"\n\
tail -100 /usr/local/tomcat/logs/catalina.out\n\
echo ""\n\
echo "=== Iniciando Tomcat ==="\n\
catalina.sh run\n\
' > /usr/local/tomcat/bin/diagnostic-enhanced.sh

RUN chmod +x /usr/local/tomcat/bin/diagnostic-enhanced.sh

# Configurar variáveis de ambiente do Tomcat
ENV CATALINA_OPTS="-Duser.timezone=America/Sao_Paulo -Dfile.encoding=UTF-8 -Xms512m -Xmx1024m"

# Expor portas
EXPOSE 9257 9258

# Iniciar com script de diagnóstico avançado
CMD ["/usr/local/tomcat/bin/diagnostic-enhanced.sh"]
