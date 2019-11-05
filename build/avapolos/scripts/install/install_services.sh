#!/bin/bash

#This script needs to run as root.
if [ "$EUID" -ne 0 ]; then
  echo "Este script precisa ser rodado como root" | log error
  exit
fi

#If the header file is present on the system.
if [ -f "/etc/avapolos/header.sh" ]; then
  #Source it.
  source /etc/avapolos/header.sh
#If it's not present.
else
  #Tell the user and exit with an error code.
  echo "Não foi encontrado o arquivo header.sh" | log error
  exit 1
fi

echo "install_services.sh" | log debug
echo "Instalando serviço principal e microsserviços." | log info

uid=$(id -u avapolos)
ip=$(bash $INSTALL_SCRIPTS_PATH/get_ip.sh)

echo "IP detectado: $ip" | log debug

cd $ROOT_PATH

echo "Extraindo pacote de dados." | log debug
tar xfz data.tar.gz

cd $SYNC_PATH
sed -i 's/INSTANCENAME/'"IES"'/g' variables.sh
mkdir -p Export/Fila
mkdir -p Import
mkdir -p dadosExportados

echo "PubkeyAuthentication yes" >> /etc/ssh/sshd_config
echo "AuthorizedKeysFile $SSH_PATH/authorized_keys " >> /etc/ssh/sshd_config
echo "IdentityFile $SSH_PATH/id_rsa " >> /etc/ssh/ssh_config

touch $SERVICES_PATH/disabled_services

echo "Instalando serviço principal." | log debug

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
systemctl enable avapolos.service | log debug

if  [ -f $INSTALL_SCRIPTS_PATH/polo ]; then
	echo "Esta instalação é um polo, ajustando parâmetros." | log info
  if [ "implementado" = "n" ]; then
    echo "Moodle AVAPolos detectado, ajustando parâmetros." | log debug
    sed -i 's/db_moodle_ies/'"db_moodle_polo"'/g' $DATA_PATH/moodle/public/config.php
    sed -i 's/SERVER/'"$ip"'/g' $DATA_PATH/moodle/public/admin/tool/avapolos/view/sincro.php
    sed -i 's/INSTANCENAME/'"POLO"'/g' $SYNC_PATH/variables.sh
  else
    echo "Moodle AVAPolos não foi detectado, ignorando." | log debug
  fi
  	echo "Rodando script para instalação de chaves privadas." | log debug
	bash $INSTALL_SCRIPTS_PATH/install_privateKey.sh
else
  echo "Esta instalação é uma IES, ajustando parâmetros" | log info
  if [ "implementado" = "n" ]; then
    echo "Moodle AVAPolos detectado, ajustando parâmetros." | log debug
    sed -i 's/SERVER/'"$ip"'/g' $DATA_PATH/moodle/public/admin/tool/avapolos/view/sincro.php
  else
    echo "Moodle AVAPolos não foi detectado, ignorando." | log debug
  fi
	echo "Rodando script para geração de chave privada" | log debug
	bash $INSTALL_SCRIPTS_PATH/generate_privateKey.sh
fi

cat $SERVICES_PATH/enabled_services > $SERVICES_PATH/stopped_services

echo "Serviços instalados com sucesso." | log info
