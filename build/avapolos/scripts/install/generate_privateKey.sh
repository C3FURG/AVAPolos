#!/usr/bin/env bash

#AVA-Polos
#generate_privateKey.sh
#This script generates the private keys used by the solution's services.

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
echo "generate_privateKey.sh" | log debug installer
echo "Gerando chaves privadas." | log info installer

#Create the directory used by the keys.
echo "Criando diretório para as chaves." | log debug installer
sudo -u avapolos mkdir -p $SSH_PATH

#Generate the keys using ssh-keygen.
echo "Rodando ssh-keygen." | log debug installer
sudo -u avapolos ssh-keygen -f $SSH_PATH/id_rsa -t rsa -P "" | log debug installer

#Copy the private to the public key.
echo "Ajustando chaves." | log debug installer
sudo -u avapolos cat $SSH_PATH/id_rsa.pub >> $SSH_PATH/authorized_keys

#Compress the keys to be saved in the solution's root path.
cd $HOME_PATH
echo "Compactando chaves." | log debug installer
tar cfz $ROOT_PATH/ssh.tar.gz .ssh

#Set up the correct permissions.
echo "Ajustando permissões." | log debug installer
chmod 700 $SSH_PATH
chmod 600 $SSH_PATH/*
chown $AVAPOLOS_USER:$AVAPOLOS_GROUP $SSH_PATH -R

#Restart both ssh services.
echo "Reiniciando serviços ssh." | log debug installer
systemctl restart sshd.service | log debug installer
systemctl restart ssh.service | log debug installer
