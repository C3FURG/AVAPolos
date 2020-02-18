#!/usr/bin/env bash

echo "Compilando downloads.avapolos" | log info data_compiler

echo "Assegurando permissões corretas e limpando diretórios de dados." | log debug data_compiler
cd $BASIC_DIR
sudo chown -R $USER:$USER .
sudo rm -rf $BASIC_DATA_DIR/downloads/*

echo "Baixando Moodle mobile e Moodle desktop." | log debug data_compiler
wget -N 'https://download.moodle.org/desktop/download.php?platform=linux&arch=32' && mv download.php* $BASIC_RESOURCES_DIR/downloads/public/instaladores/moodledesktoplinux32.tgz | log debug data_compiler
wget -N 'https://download.moodle.org/desktop/download.php?platform=linux&arch=64' && mv download.php* $BASIC_RESOURCES_DIR/downloads/public/instaladores/moodledesktoplinux64.tgz | log debug data_compiler
wget -N 'https://download.moodle.org/desktop/download.php?platform=windows' && mv download.php* $BASIC_RESOURCES_DIR/downloads/public/instaladores/moodledesktopwindows.zip | log debug data_compiler
wget -N 'https://download.moodle.org/desktop/download.php?platform=android' && mv download.php* $BASIC_RESOURCES_DIR/downloads/public/instaladores/moodlemobile.apk | log debug data_compiler
echo "Instaladores baixados com sucesso." | log debug data_compiler

echo "Copiando recursos do serviço." | log debug data_compiler
cp -rf $BASIC_RESOURCES_DIR/downloads/public $BASIC_DATA_DIR/downloads/

echo "Iniciando webserver" | log debug data_compiler

docker-compose up -d downloads

testURL "http://downloads.avapolos"                                       | log debug data_compiler
testURL "http://downloads.avapolos/instaladores/moodledesktoplinux32.tgz" | log debug data_compiler
testURL "http://downloads.avapolos/instaladores/moodledesktoplinux64.tgz" | log debug data_compiler
testURL "http://downloads.avapolos/instaladores/moodledesktopwindows.zip" | log debug data_compiler
testURL "http://downloads.avapolos/instaladores/moodlemobile.apk"         | log debug data_compiler

echo "Excluindo diretório temporário." | log debug data_compiler
rm -rf $tmp
