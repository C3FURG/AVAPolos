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

echo "install_privateKey.sh" | log debug installer
echo "Instalando chave privada." | log info installer

echo "Criando diretório para as chaves." | log debug installer
sudo -u avapolos mkdir -p $SSH_PATH

echo "Extraindo chaves da IES." | log debug installer
cp $ROOT_PATH/ssh.tar.gz $HOME_PATH
cd $HOME_PATH
tar xvfz ssh.tar.gz

echo "Ajustando permissões." | log debug installer
chmod 700 $SSH_PATH
chmod 600 $SSH_PATH/*
chown $AVAPOLOS_USER:$AVAPOLOS_GROUP $SSH_PATH -R

echo "Reiniciando serviços ssh." | log debug installer
systemctl restart sshd.service
systemctl restart ssh.service
