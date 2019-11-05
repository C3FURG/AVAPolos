#!/bin/bash

#This script needs to run as root.
if [ "$EUID" -ne 0 ]; then
  echo "Este script precisa ser rodado como root" | log error
  exit
fi

#If the header file is present in the system.
if [ -f "/etc/avapolos/header.sh" ]; then
  #Source it.
  source /etc/avapolos/header.sh
#If it's not present.
else
  #Tell the user and exit with an error code.
  echo "Não foi encontrado o arquivo header.sh" | log error
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
  echo "Não foram encontrados os arquivos functions.sh e variables.sh da sync." | log error
  exit 1
fi

#sudo avapolos switch name

#Start the cronometer
start=$(date +%s)

services="$(cat $SERVICES_PATH/enabled_services)"
if [ -z "$(echo $services | grep -o moodle)" ]; then
  echo "Moodle não está habilitado, pulando etapa de sincronização." | log info
else
  echo "Executando sincronização..."
  createMasterFileDirList
  createSyncFileDirList
  chown -R avapolos:avapolos $masterFileDirListPath $syncFileDirListPath

  createControlRecord 0 E 'instaladorAvapolos'
  stopDBMaster
  ###TO-DO: tornar moodle inacessivel
  clearQueue
  #apagando o registro de controle do clone para que uma nova clonagem possa ser gerada quando desejad
fi

stop

echo "Copiando arquivos." | log debug

cd $ROOT_PATH

tar cfz data.tar.gz data

rm -rf $TMP_PATH
mkdir -p $TMP_PATH
rsync -av $ROOT_PATH/* $TMP_PATH --exclude=data | log debug
sudo touch $TMP_PATH/scripts/install/polo
sudo rm -rf $TMP_PATH/{Import/*,Export/Fila/*}
rm -rf data.tar.gz

cd $TMP_PATH

echo "Compactando clonagem, pode demorar um pouco." | log debug
tar cfz AVAPolos.tar.gz *

mkdir preinstall
rsync -av $INSTALLER_DIR_PATH/* preinstall --exclude=AVAPolos.tar.gz | log debug
cp -rf AVAPolos.tar.gz preinstall
cd preinstall
makeself --target $INSTALLER_DIR_PATH --nooverwrite --needroot . AVAPolos_instalador_POLO "Instalador da solução AVAPolos" "./startup.sh" 2>&1 | log debug

cp -rf AVAPolos_instalador_POLO /opt
chmod 755 /opt/AVAPolos_instalador_POLO
sudo rm -r $TMP_PATH

end=$(date +%s)
runtime=$((end-start))

echo "---- Clonagem concluída ----" | log info
echo "Instalador disponível: /opt/AVAPolos_instalador_POLO" | log info
echo "Tamanho: $(du -h /opt/AVAPolos_instalador_POLO | awk {'print $1'})" | log info
echo "Em "$runtime"s." | log info

echo "Reiniciando serviços." | log info

start
