#!/usr/bin/env bash

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

log debug "install_services.sh" 
log info "Instalando serviço principal e microsserviços." 

uid=$(id -u avapolos)
ip=$(bash $INSTALL_SCRIPTS_PATH/get_ip.sh)

log debug "IP detectado: $ip"

cd $ROOT_PATH

log debug "Extraindo pacote de dados." 
tar xfz data.tar.gz

cd $SYNC_PATH
#sed -i 's/INSTANCENAME/'"IES"'/g' variables.sh
mkdir -p Export/Fila
mkdir -p Import
mkdir -p dadosExportados

echo "PubkeyAuthentication yes" >> /etc/ssh/sshd_config
echo "AuthorizedKeysFile $SSH_PATH/authorized_keys " >> /etc/ssh/sshd_config
echo "IdentityFile $SSH_PATH/id_rsa " >> /etc/ssh/ssh_config

touch $SERVICES_PATH/disabled_services

log debug "Instalando serviço principal." 

echo -e "
[Unit]
Description=avapolos service

[Service]
Type=simple
ExecStart=/bin/bash $SERVICE_PATH/service_daemon.sh

[Install]
WantedBy=multi-user.target
" > /etc/systemd/system/avapolos.service
chmod 640 /etc/systemd/system/avapolos.service
systemctl enable avapolos.service

if  [ -f $INSTALL_SCRIPTS_PATH/polo ]; then
	log info "Esta instalação é um polo, ajustando parâmetros."
  log debug "Moodle AVAPolos detectado, ajustando parâmetros." 
  sed -i 's/db_moodle_ies/'"db_moodle_polo"'/g' $DATA_PATH/moodle/public/config.php
  sed -i 's/SERVER/'"$ip"'/g' $DATA_PATH/moodle/public/admin/tool/avapolos/view/sincro.php
  sed -i 's/instance\=\"IES\"/'instance=\"POLO\"'/g' $SYNC_PATH/variables.sh
  log debug "Rodando script para instalação de chaves privadas." 
	bash $INSTALL_SCRIPTS_PATH/install_privateKey.sh
else
  log info "Esta instalação é uma IES, ajustando parâmetros" 
  sed -i 's/instance\=\"INSTANCENAME\"/'instance=\"IES\"'/g' $SYNC_PATH/variables.sh
  log debug "Moodle AVAPolos detectado, ajustando parâmetros." 
  sed -i 's/SERVER/'"$ip"'/g' $DATA_PATH/moodle/public/admin/tool/avapolos/view/sincro.php
	log debug "Rodando script para geração de chave privada"
	bash $INSTALL_SCRIPTS_PATH/generate_privateKey.sh
fi

log debug "ID da rede avapolos:"
docker network create -d bridge --gateway 172.12.0.1 --subnet 172.12.0.0/16 avapolos
log debug "ID da rede proxy:"
docker network create --driver bridge proxy

cat $SERVICES_PATH/enabled_services > $SERVICES_PATH/stopped_services

log info "Serviços instalados com sucesso." 
