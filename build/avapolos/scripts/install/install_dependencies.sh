#!/usr/bin/env bash

#AVA-Polos
#install_dependencies.sh
#This script installs the dependencies.

#This script needs to run as root.
if [ "$EUID" -ne 0 ]; then
  echo "Este script precisa ser rodado como root" | log error installer
  exit
fi

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

#Log what script is being run.
echo "install_dependencies.sh" | log debug installer
echo "Instalando dependências." | log info installer

#Log what path is being used to search for dependencies.
echo "Buscando dependências no diretório: $DEPENDENCIES_PATH" | log debug installer
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
    echo "Aguardando outras instalações terminarem.," | log info installer
    sleep 3
done

apt-get install -y --fix-missing $packages 

echo "Instalando docker-compose" | log debug installer
sudo cp docker-compose /usr/local/bin/
sudo chmod +x /usr/local/bin/docker-compose

#dpkg -i *.deb 2>&1 | log debug installer

#   echo "Docker já está instalado" | log debug installer
#   if [ "$INTERACTIVE" = "y" ]; then
#     input "Deseja instalar a versão compatível com AVAPolos?" "sim" "nao" 0 "Selecione uma opção."
#     if [ -x "$(command -v docker)" ]; then
#       if [ "$option" = "sim" ]; then
#         echo "Usuário selecionou a reinstalação do Docker." | log info installer
#         bash $INSTALL_SCRIPTS_PATH/uninstall_docker.sh
#         cd docker
#         dpkg_install *.deb
#       fi
#   else
#     bash $INSTALL_SCRIPTS_PATH/uninstall_docker.sh
#     cd docker
#     dpkg_install *.deb
#   fi
# else
#   cd docker
#   dpkg_install *.deb
# fi

checks=("docker" "docker-compose")

for item in ${checks[@]}; do
  if [ -x "$(command -v "$item")" ]; then
    echo "$item instalado com sucesso." | log info installer
  else
  	echo "Houve um erro na instalação do $item, tente novamente." | log error installer
    exit 1
  fi
done

# rm /etc/apt/sources.list
# mv /etc/apt/sources.list.old /etc/apt/sources.list
