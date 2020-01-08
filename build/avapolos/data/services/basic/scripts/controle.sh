#!/usr/bin/env bash

echo "Compilando controle.avapolos" | log info data_compiler

echo "Assegurando permissões corretas e limpando diretórios de dados." | log debug data_compiler
cd $BASIC_DIR
sudo chown -R $USER:$USER .
sudo rm -rf $BASIC_DATA_DIR/controle/*
mkdir -p $BASIC_DATA_DIR/controle/public


echo "Copiando recursos do serviço." | log debug data_compiler
cp -rf $BASIC_RESOURCES_DIR/controle/public $BASIC_DATA_DIR/controle
mkdir -p $BASIC_DATA_DIR/controle/public/vendor/{fontawesome-free,jquery}

tmp=$(mktemp -d -t controle_vendor_download.XXXXXXX)
echo "Criando diretório temporário para download de recursos: $tmp" | log debug data_compiler
echo "Executando o download dos vendors." | log debug data_compiler
wget -O $tmp/fontawesome-free.zip https://use.fontawesome.com/releases/v5.11.2/fontawesome-free-5.11.2-web.zip | log debug data_compiler
cd $tmp
unzip fontawesome-free.zip | log debug data_compiler
cd $BASIC_DIR
cp -rf $tmp/fontawesome-free-5.11.2-web/* $BASIC_DATA_DIR/controle/public/vendor/fontawesome-free/
wget -O $BASIC_DATA_DIR/controle/public/vendor/popper.min.js "https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.12.9/umd/popper.min.js"
wget -O $BASIC_DATA_DIR/controle/public/vendor/jquery-3.2.1.slim.min.js "https://code.jquery.com/jquery-3.2.1.slim.min.js"
wget -O $BASIC_DATA_DIR/controle/public/vendor/bootstrap.min.css "https://maxcdn.bootstrapcdn.com/bootstrap/4.4.1/css/bootstrap.min.css"
wget -O $BASIC_DATA_DIR/controle/public/vendor/bootstrap.min.js "https://maxcdn.bootstrapcdn.com/bootstrap/4.4.1/js/bootstrap.min.js"
echo "vendors instalados com sucesso no serviço." | log debug data_compiler


echo "Iniciando webserver" | log debug data_compiler
docker-compose up -d controle

testURL "http://controle.avapolos" | log debug data_compiler

echo "Excluindo diretório temporário." | log debug data_compiler
rm -rf $tmp
