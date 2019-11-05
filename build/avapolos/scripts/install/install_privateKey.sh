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

echo "install_privateKey.sh" | log debug
echo "Instalando chave privada." | log info

echo "Criando diretório para as chaves." | log debug
sudo -u avapolos mkdir -p $SSH_PATH

echo "Extraindo chaves da IES." | log debug
cp $ROOT_PATH/ssh.tar.gz $HOME_PATH
cd $HOME_PATH
tar xvfz ssh.tar.gz

echo "Ajustando permissões." | log debug
chmod 700 $SSH_PATH
chmod 600 $SSH_PATH/*
chown $AVAPOLOS_USER:$AVAPOLOS_GROUP $SSH_PATH -R

echo "Reiniciando serviços ssh." | log debug
systemctl restart sshd.service
systemctl restart ssh.service
