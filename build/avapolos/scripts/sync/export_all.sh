#!/usr/bin/env bash

#This script needs to run as root.
if [ "$EUID" -ne 0 ]; then
  log error "Este script precisa ser rodado como root" 
  exit
fi

#If the header file is present in the system.
if [ -f "/etc/avapolos/header.sh" ]; then
  #Source it.
  source /etc/avapolos/header.sh
#If it's not present.
else
  #Tell the user and exit with an error code.
  log error "Não foi encontrado o arquivo header.sh" 
  exit 1
fi

#If the header files for the sync are present in the system.
if [ -f $SYNC_PATH/functions.sh ] && [ -f $SYNC_PATH/variables.sh ]; then
  #Source them.
  source $SYNC_PATH/functions.sh
  source $SYNC_PATH/variables.sh
#If they aren't present.
else
  #Tell the user and exit with an error code.
  log error "Não foram encontrados os arquivos functions.sh e variables.sh da sync." 
  exit 1
fi

#sudo avapolos switch name

#Start the cronometer
start=$(date +%s)

services="$(cat $SERVICES_PATH/enabled_services)"
if [ -z "$(echo $services | grep -o moodle)" ]; then
  log info "Moodle não está habilitado, pulando etapa de sincronização." 
else
  echo "Executando sincronização..."
  createMasterFileDirList
  createSyncFileDirList
  chown -R avapolos:avapolos $masterFileDirListPath $syncFileDirListPath

  createControlRecord 0 E 'instaladorAVAPolos'
  stopDBMaster
  ###TO-DO: tornar moodle inacessivel
  clearQueue
  #apagando o registro de controle do clone para que uma nova clonagem possa ser gerada quando desejad
fi

source $NOIP_ENV_PATH
previousDomain=$DOMAIN

bash $INSTALL_SCRIPTS_PATH/setup_dns.sh null null avapolos

stop

log debug "Copiando arquivos." 

cd $ROOT_PATH

tar cfz data.tar.gz data

rm -rf $TMP_PATH
mkdir -p $TMP_PATH
rsync -av $ROOT_PATH/* $TMP_PATH --exclude=data
sudo touch $TMP_PATH/scripts/install/polo
sudo rm -rf $TMP_PATH/{Import/*,Export/Fila/*}
rm -rf data.tar.gz

cd $TMP_PATH

log debug "Compactando clonagem, pode demorar um pouco." 
tar cfz AVAPolos.tar.gz *

mkdir preinstall
rsync -av $INSTALLER_DIR_PATH/* preinstall --exclude=AVAPolos.tar.gz
cp -rf AVAPolos.tar.gz preinstall
cd preinstall

path="$CLONE_INSTALLER_PATH/$CLONE_INSTALLER_FILENAME"

makeself --target $INSTALLER_DIR_PATH --nooverwrite --needroot . $CLONE_INSTALLER_FILENAME "Instalador da solução AVAPolos" "./startup.sh" 2>&1

cp -rf $CLONE_INSTALLER_PATH $path
chmod 755 $path
sudo rm -r $TMP_PATH

end=$(date +%s)
runtime=$((end-start))

log info "---- Clonagem concluída ----" 
log info "Instalador disponível: $path"
log info "Tamanho: $(du -h $path | awk {'print $1'})"
log info "Em "$runtime"s." 

log info "Reiniciando serviços." 

bash $INSTALL_SCRIPTS_PATH/setup_dns.sh null null $previousDomain

start
