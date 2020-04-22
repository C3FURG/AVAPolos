#!/usr/bin/env bash

#----------------------------------------------#
# AVAPolos - Script de desconfiguração de rede #
#----------------------------------------------#

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

log debug "uninstall_networking.sh" 
log info "Retornando a rede para as configurações anteriores." 

#----------------------------------------------------------

if [ -f $NETWORKING_PATH/enable ]; then
  cd $NETWORKING_PATH
  docker-compose down
  rm -rf enable
fi

if [ -f /etc/init.d/network-manager ]; then
  log debug "Habilitando serviço padrão de gerenciamento de redes." 
  sudo mv /usr/lib/NetworkManager/conf.d/10-globally-managed-devices.conf /usr/lib/NetworkManager/conf.d/10-globally-managed-devices.conf.original
  sudo touch /usr/lib/NetworkManager/conf.d/10-globally-managed-devices.conf
  sudo systemctl unmask NetworkManager 2>&1
  sudo systemctl enable NetworkManager 2>&1
  sudo systemctl start NetworkManager 2>&1 
fi

log debug "Habilitando o serviço padrão de resolução de nomes" 
sudo systemctl unmask systemd-resolved 2>&1
sudo systemctl enable systemd-resolved 2>&1
sudo systemctl start systemd-resolved 2>&1 

log debug "Desfazendo mudanças no arquivo /etc/hosts"
sudo sed -i '/avapolos/d' /etc/hosts
sudo sed -i '/AVA-Polos/d' /etc/hosts
sudo sed -i '/AVAPolos/d' /etc/hosts

log debug "Desfazendo mudanças no arquivo interfaces" 
undoConfig /etc/network/interfaces

log debug "Desfazendo mudanças no arquivo resolv.conf" 
rm /etc/resolv.conf
sudo ln -sf /run/systemd/resolve/resolv.conf /etc/resolv.conf

if [ -d "/etc/netplan" ]; then
  log debug "Restaurando o netplan" 
  apt-get install -y netplan.io
  log debug "Ativando netplan" 
  sudo netplan apply 2>&1
fi

log debug "Reiniciando rede" 
sudo systemctl restart networking
sudo systemctl restart NetworkManager
