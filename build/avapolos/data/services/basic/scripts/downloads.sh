#!/usr/bin/env bash

log info "Compilando downloads.avapolos" 

mkdir -p $BASIC_DATA_DIR/downloads/public

log debug "Baixando Moodle mobile e Moodle desktop." 
wget -N 'https://download.moodle.org/desktop/download.php?platform=linux&arch=32' && cp -n 'download.php?platform=linux&arch=32' $BASIC_RESOURCES_DIR/downloads/public/instaladores/moodledesktoplinux32.tgz
wget -N 'https://download.moodle.org/desktop/download.php?platform=linux&arch=64' && cp -n 'download.php?platform=linux&arch=64' $BASIC_RESOURCES_DIR/downloads/public/instaladores/moodledesktoplinux64.tgz
wget -N 'https://download.moodle.org/desktop/download.php?platform=windows' && cp -n 'download.php?platform=windows' $BASIC_RESOURCES_DIR/downloads/public/instaladores/moodledesktopwindows.zip
wget -N 'https://download.moodle.org/desktop/download.php?platform=android' && cp -n 'download.php?platform=android' $BASIC_RESOURCES_DIR/downloads/public/instaladores/moodlemobile.apk
log debug "Instaladores baixados com sucesso." 

log debug "Copiando recursos do serviço." 
cp -rf $BASIC_RESOURCES_DIR/downloads/public $BASIC_DATA_DIR/downloads/

log debug "Iniciando webserver" 

docker-compose up -d downloads

sleep 3
testURL "http://downloads.avapolos"                                       
testURL "http://downloads.avapolos/instaladores/moodledesktoplinux32.tgz" 
testURL "http://downloads.avapolos/instaladores/moodledesktoplinux64.tgz" 
testURL "http://downloads.avapolos/instaladores/moodledesktopwindows.zip" 
testURL "http://downloads.avapolos/instaladores/moodlemobile.apk"         

log debug "Excluindo diretório temporário." 
rm -rf $tmp
