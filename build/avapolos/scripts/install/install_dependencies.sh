#!/usr/bin/env bash

#AVA-Polos
#install_dependencies.sh
#This script installs the dependencies.

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
log debug "install_dependencies.sh" 
log info "Instalando dependências." 

#Log what path is being used to search for dependencies.
log debug "Buscando dependências no diretório: $DEPENDENCIES_PATH"
cd $DEPENDENCIES_PATH

#string="deb [trusted=yes] file://$DEPENDENCIES_PATH ./"
string="deb [trusted=yes] file:///opt/avapolos/resources/dependencies ./"

mv /etc/apt/sources.list /etc/apt/sources.list.old

echo $string > /etc/apt/sources.list
chmod 664 /etc/apt/sources.list

#sed -i "1i $string" /etc/apt/sources.list

apt-get update

packages=$(echo $(cat $DEPENDENCIES_PATH/packages | sed -E -e 's/[[:blank:]]+/\n/g'  | grep -v "docker-compose" | grep -v "netplan.io"))

echo "Instalando pacotes: $packages"

while fuser /var/lib/dpkg/lock >/dev/null 2>&1 ; do
  log info "Aguardando outras instalações terminarem." 
  sleep 3
done

apt-get install -y --fix-missing $packages

log debug "Instalando docker-compose" 
sudo cp docker-compose /usr/local/bin/
sudo chmod +x /usr/local/bin/docker-compose

checks=("docker" "docker-compose")

for item in ${checks[@]}; do
  if [ -x "$(command -v "$item")" ]; then
log info  "$item instalado com sucesso." 
  else
  	log error "Houve um erro na instalação do $item, tente novamente."
    exit 1
  fi
done

# rm /etc/apt/sources.list
# mv /etc/apt/sources.list.old /etc/apt/sources.list
