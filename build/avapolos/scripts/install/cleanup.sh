#!/usr/bin/env bash

#AVA-Polos
#clenup.sh
#This script executes the post-install cleaning operations.

#This script needs to run as root.
if [ "$EUID" -ne 0 ]; then
  echo "Este script precisa ser rodado como root"
  exit
fi

#If the header file is present on the system.
if [ -f "/etc/avapolos/header.sh" ]; then
  #Source it.
  source /etc/avapolos/header.sh
#If it's not present.
else
  #Tell the user and exit with an error code.
  echo "Não foi encontrado o arquivo header.sh"
  exit 1
fi

#Log what script is being run.
log debug "cleanup.sh" 
log info "Executando limpezas finais." 

#Add the avapolos' user to the system.
log debug "Adicionando usuário $AVAPOLOS_USER ao grupo Docker." 
#Add him to the docker group.
usermod -aG docker $AVAPOLOS_USER

#Remove the installation's files.
log debug "Removendo arquivos de instalação." 
sudo rm -rf $ROOT_PATH/AVAPolos.tar.gz

#Set up the required permissions.
log debug "Assegurando permissões corretas sobre os diretórios necessários." 
chown $(id -u $AVAPOLOS_USER):$(id -g $AVAPOLOS_GROUP) -R $ROOT_PATH
chown $(id -u $AVAPOLOS_USER):$(id -g $AVAPOLOS_GROUP) -R $ETC_PATH
chmod 740 $ROOT_PATH -R
