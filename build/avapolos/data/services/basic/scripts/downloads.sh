#!/usr/bin/env bash

echo "Compilando downloads.avapolos" | log info data_compiler

echo "Assegurando permissões corretas e limpando diretórios de dados." | log debug data_compiler
cd $BASIC_DIR
sudo chown -R $USER:$USER .
sudo rm -rf $BASIC_DATA_DIR/downloads/*
mkdir -p $BASIC_DATA_DIR/downloads/public/fontawesome

echo "Copiando recursos do serviço." | log debug data_compiler
cp -rf $BASIC_RESOURCES_DIR/downloads/public $BASIC_DATA_DIR/downloads/

tmp=$(mktemp -d -t downloads_vendor_download.XXXXXXX)
echo "Criando diretório temporário para download de recursos: $tmp" | log debug data_compiler
echo "Executando o download do fontawesome." | log debug data_compiler
wget -O $tmp/fontawesome.zip https://use.fontawesome.com/releases/v5.11.2/fontawesome-free-5.11.2-web.zip | log debug data_compiler
cd $tmp
unzip fontawesome.zip | log debug data_compiler
cd $BASIC_DIR
cp -rf $tmp/fontawesome-free-5.11.2-web/* $BASIC_DATA_DIR/downloads/public/fontawesome
echo "fontawesome instalado com sucesso no serviço." | log debug data_compiler

echo "Executando o download dos instaladores do Moodle Mobile e Desktop."
wget -O $BASIC_DATA_DIR/downloads/public/instaladores/moodledesktoplinux32.tgz https://download.moodle.org/desktop/download.php?platform=linux'&'arch=32 | log debug data_compiler
wget -O $BASIC_DATA_DIR/downloads/public/instaladores/moodledesktoplinux64.tgz https://download.moodle.org/desktop/download.php?platform=linux'&'arch=64 | log debug data_compiler
wget -O $BASIC_DATA_DIR/downloads/public/instaladores/moodledesktopwindows.zip https://download.moodle.org/desktop/download.php?platform=windows         | log debug data_compiler
wget -O $BASIC_DATA_DIR/downloads/public/instaladores/moodlemobile.apk https://download.moodle.org/desktop/download.php?platform=android                 | log debug data_compiler
echo "Instaladores baixados com sucesso." | log debug data_compiler

echo "Iniciando webserver" | log debug data_compiler

docker-compose up -d downloads

testURL "http://downloads.avapolos"                                       | log debug data_compiler
testURL "http://downloads.avapolos/instaladores/moodledesktoplinux32.tgz" | log debug data_compiler
testURL "http://downloads.avapolos/instaladores/moodledesktoplinux64.tgz" | log debug data_compiler
testURL "http://downloads.avapolos/instaladores/moodledesktopwindows.zip" | log debug data_compiler
testURL "http://downloads.avapolos/instaladores/moodlemobile.apk"         | log debug data_compiler

echo "Excluindo diretório temporário." | log debug data_compiler
rm -rf $tmp
