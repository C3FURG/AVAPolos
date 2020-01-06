#!/usr/bin/env bash

#AVA-Polos
#get_ip.sh
#This utility script returns the host machine's ip.

#If the header file is present on the system.
if [ -f "/etc/avapolos/header.sh" ]; then
  #Source it.
  source /etc/avapolos/header.sh
#If it's not present.
else
  #Tell the user and exit with an error code.
  echo "Não foi encontrado o arquivo header.sh" | log error installer
  exit 1
fi

#Get the main interface
interface=$(cat $INSTALL_SCRIPTS_PATH/interface)
if [ -z "$interface" ]; then
  echo "O arquivo de interface não foi encontrado!"
  exit 1
fi

#Return the ip using ip command and some magic.
ip=$(ip -o -f inet addr show | grep "$interface" | awk '/scope global/ {print $4}' | cut -d "/" -f1)
echo $ip
