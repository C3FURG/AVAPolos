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
log debug "generate_privateKey.sh" 
log info "Gerando chaves privadas." 

#Create the directory used by the keys.
log debug "Criando diretório para as chaves." 
sudo -u avapolos mkdir -p $SSH_PATH

#Generate the keys using ssh-keygen.
log debug "Rodando ssh-keygen." 
sudo -u avapolos ssh-keygen -f $SSH_PATH/id_rsa -t rsa -P ""

#Copy the private to the public key.
log debug "Ajustando chaves." 
sudo -u avapolos cat $SSH_PATH/id_rsa.pub >> $SSH_PATH/authorized_keys

#Compress the keys to be saved in the solution's root path.
cd $HOME_PATH
log debug "Compactando chaves." 
tar cfz $ROOT_PATH/ssh.tar.gz .ssh

#Set up the correct permissions.
log debug "Ajustando permissões." 
chmod 700 $SSH_PATH
chmod 600 $SSH_PATH/*
chown $AVAPOLOS_USER:$AVAPOLOS_GROUP $SSH_PATH -R

#Restart both ssh services.
log debug "Reiniciando serviços ssh." 
systemctl restart sshd.service
systemctl restart ssh.service 
