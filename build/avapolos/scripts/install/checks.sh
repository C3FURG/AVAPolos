#!/usr/bin/env bash

#AVA-Polos
#checks.sh
#This script checks for incompatibilities in the target system and reports or fixes them.

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

#Log what script is being run.
echo "checks.sh" | log debug
echo "Executando checagens iniciais." | log info

#If the system's version is compatible.
if [ "$(lsb_release -rs)" = "18.04" ]; then
  #Tell the user.
  echo "Ubuntu 18.04 é compatível com AVAPolos, continuando..." | log info
#If it's not compatible.
else
  #Tell the user and exit with a error code.
  echo "Seu sistema é incompatível com AVAPolos." | log error
  exit 1
fi

#Declare what services need to terminate in order to install the solution.
services=("apache2")

#For every service in the services list.
for i in "${services[@]}"; do
  #If the service is active
  if $(systemctl is-active --quiet $i); then
    #Stop it and tell the user.
    echo "O servico $i esta rodando, será finalizado" | log info
    systemctl stop "$i".service
  fi
done

#While dpkg is locked.
while fuser /var/lib/dpkg/lock >/dev/null 2>&1 ; do
  #Tell the user and wait 3 seconds for the next check.
  echo "Aguardando outras instalações terminarem.," | log info
  sleep 3
done
