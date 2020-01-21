#!/usr/bin/env bash

#Debugging
#set -x

#$1-> Username
#$2-> Password
#$3-> Domain

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

echo "
USER=\"$1\"
PASS=\"$2\"
HOST=\"$3\"
" > $NOIP_ENV_PATH

add_service noip.yml
enable_service noip.yml

restart
