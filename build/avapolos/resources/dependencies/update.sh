#!/usr/bin/env bash

if [ "$EUID" -eq 0 ]; then
	echo "Este script NÃO pode ser rodado como root!"
  exit 1
fi

log debug "dependencies/update.sh"

#Begin the cronometer.
start=$(date +%s)

#Clean up and update.
sudo apt-get update

log debug "Limpando arquivos anteriores"
rm -rf *.deb
rm -rf Packages
rm -rf docker-compose

#Setting the packages to be downloaded.
packages=$(cat packages)
log debug "Baixando os seguintes pacotes e suas dependências: $packages"

for pkg in $packages; do
	log debug "Baixando dependências do pacote $pkg: $(apt-rdepends $pkg | grep -v "^ " | grep -v debconf-2.0)"
	apt-get download $(apt-rdepends $pkg | grep -v "^ " | grep -v debconf-2.0)
done

dpkg-scanpackages . /dev/null > Packages

log debug "Baixando o docker-compose"
sudo curl -L "https://github.com/docker/compose/releases/download/1.24.1/docker-compose-$(uname -s)-$(uname -m)" -o ./docker-compose

#Set up the permissions.
chmod 744 -R *.deb

#Stopping the cronometer
end=$(date +%s)

#Calculating the runtime.
runtime=$((end-start))

#Let the user know it's done and the runtime.
log info "Dependências atualizadas com sucesso, em "$runtime"s."
