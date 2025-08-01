@echo off
REM Script para preparar os arquivos do PJE-Calc para transferência para a VPS Linux

echo Preparando arquivos do PJE-Calc para transferência...

REM Definir diretórios
set SOURCE_DIR=%~dp0..\pjecalc-windows64-2.13.2
set TARGET_DIR=%~dp0transfer

REM Criar estrutura de diretórios
echo Criando estrutura de diretórios...
mkdir "%TARGET_DIR%"
mkdir "%TARGET_DIR%\bin"
mkdir "%TARGET_DIR%\tomcat"
mkdir "%TARGET_DIR%\tomcat\conf"
mkdir "%TARGET_DIR%\tomcat\webapps"
mkdir "%TARGET_DIR%\.dados"

REM Copiar arquivos necessários
echo Copiando arquivos...
copy "%SOURCE_DIR%\bin\pjecalc.jar" "%TARGET_DIR%\bin\"
xcopy /E /I /H "%SOURCE_DIR%\tomcat\conf" "%TARGET_DIR%\tomcat\conf"
xcopy /E /I /H "%SOURCE_DIR%\tomcat\webapps" "%TARGET_DIR%\tomcat\webapps"
xcopy /E /I /H "%SOURCE_DIR%\.dados" "%TARGET_DIR%\.dados"

REM Copiar scripts e configurações Linux
echo Copiando scripts e configurações Linux...
xcopy /E /I /H "%~dp0scripts" "%TARGET_DIR%\scripts"
copy "%~dp0docker-compose.yml" "%TARGET_DIR%\"
copy "%~dp0migrate-pjecalc.sh" "%TARGET_DIR%\"
copy "%~dp0README.md" "%TARGET_DIR%\"

REM Criar arquivo de instruções
echo Criando arquivo de instruções...
echo # Instruções para migração do PJE-Calc para VPS com EasyPanel > "%TARGET_DIR%\INSTRUCOES.txt"
echo. >> "%TARGET_DIR%\INSTRUCOES.txt"
echo 1. Transfira todos os arquivos desta pasta para a VPS >> "%TARGET_DIR%\INSTRUCOES.txt"
echo 2. Na VPS, execute os seguintes comandos: >> "%TARGET_DIR%\INSTRUCOES.txt"
echo    chmod +x migrate-pjecalc.sh >> "%TARGET_DIR%\INSTRUCOES.txt"
echo    sudo ./migrate-pjecalc.sh >> "%TARGET_DIR%\INSTRUCOES.txt"
echo. >> "%TARGET_DIR%\INSTRUCOES.txt"
echo 3. Após a instalação, acesse o PJE-Calc em: http://seu-servidor:9257/pjecalc >> "%TARGET_DIR%\INSTRUCOES.txt"
echo. >> "%TARGET_DIR%\INSTRUCOES.txt"
echo Para mais informações, consulte o arquivo README.md >> "%TARGET_DIR%\INSTRUCOES.txt"

echo Preparação concluída!
echo Os arquivos estão prontos para transferência no diretório: %TARGET_DIR%
echo.
pause
