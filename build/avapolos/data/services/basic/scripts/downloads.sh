#!/usr/bin/env bash

echo "Compilando downloads.avapolos" | log info data_compiler

mkdir -p $BASIC_DATA_DIR/downloads/public

echo "Baixando Moodle mobile e Moodle desktop." | log debug data_compiler
wget -N 'https://download.moodle.org/desktop/download.php?platform=linux&arch=32' && cp -n 'download.php?platform=linux&arch=32' $BASIC_RESOURCES_DIR/downloads/public/instaladores/moodledesktoplinux32.tgz | log debug data_compiler
wget -N 'https://download.moodle.org/desktop/download.php?platform=linux&arch=64' && cp -n 'download.php?platform=linux&arch=64' $BASIC_RESOURCES_DIR/downloads/public/instaladores/moodledesktoplinux64.tgz | log debug data_compiler
wget -N 'https://download.moodle.org/desktop/download.php?platform=windows' && cp -n 'download.php?platform=windows' $BASIC_RESOURCES_DIR/downloads/public/instaladores/moodledesktopwindows.zip | log debug data_compiler
wget -N 'https://download.moodle.org/desktop/download.php?platform=android' && cp -n 'download.php?platform=android' $BASIC_RESOURCES_DIR/downloads/public/instaladores/moodlemobile.apk | log debug data_compiler
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
