@echo off
REM Script para enviar os arquivos para o GitHub

echo Configurando o Git e enviando arquivos para o GitHub...

REM Configurar usuário e email do Git
git config --global user.name "vicelmoalencar"
git config --global user.email "vicelmoalencar@gmail.com"

REM Inicializar repositório Git
git init

REM Adicionar arquivos ao repositório
git add .

REM Fazer commit dos arquivos
git commit -m "Migracao do PJE-Calc para VPS com EasyPanel"

REM Adicionar repositório remoto
git remote add origin https://github.com/vicelmoalencar/pjecalconline.git

REM Enviar arquivos para o GitHub
git push -u origin master

echo Processo concluído!
pause
