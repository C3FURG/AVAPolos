#!/usr/bin/env bash

#----------------------------------------------#
# AVAPolos - Script de desconfiguração de rede #
#----------------------------------------------#

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

echo "uninstall_networking.sh" | log debug
echo "Retornando a rede para as configurações anteriores." | log info

#----------------------------------------------------------

if [ -f $NETWORKING_PATH/enable ]; then
  cd $NETWORKING_PATH
  docker-compose down 2>&1 | log debug
  rm -rf enable
fi

if [ -f /etc/init.d/network-manager ]; then
  echo "Habilitando serviço padrão de gerenciamento de redes." | log debug
  sudo mv /usr/lib/NetworkManager/conf.d/10-globally-managed-devices.conf /usr/lib/NetworkManager/conf.d/10-globally-managed-devices.conf.original
  sudo touch /usr/lib/NetworkManager/conf.d/10-globally-managed-devices.conf
  sudo systemctl unmask NetworkManager 2>&1 | log debug
  sudo systemctl enable NetworkManager 2>&1 | log debug
  sudo systemctl start NetworkManager 2>&1 | log debug
fi

echo "Habilitando o serviço padrão de resolução de nomes" | log debug
sudo systemctl unmask systemd-resolved 2>&1 | log debug
sudo systemctl enable systemd-resolved 2>&1 | log debug
sudo systemctl start systemd-resolved 2>&1 | log debug

echo "Desfazendo mudanças no arquivo /etc/hosts" | log debug
sudo sed -i '/avapolos/d' /etc/hosts
sudo sed -i '/AVA-Polos/d' /etc/hosts
sudo sed -i '/AVAPolos/d' /etc/hosts

echo "Desfazendo mudanças no arquivo interfaces" | log debug
undoConfig /etc/network/interfaces

echo "Desfazendo mudanças no arquivo resolv.conf" | log debug
rm /etc/resolv.conf
sudo ln -sf /run/systemd/resolve/resolv.conf /etc/resolv.conf

if [ -d "/etc/netplan" ]; then
  echo "Restaurando o netplan" | log debug
  apt-get install -y netplan.io | log debug
  echo "Ativando netplan" | log debug
  sudo netplan apply 2>&1 | log debug
fi

echo "Reiniciando rede" | log debug
sudo systemctl restart networking 2>&1 | log debug
sudo systemctl restart NetworkManager 2>&1 | log debug
