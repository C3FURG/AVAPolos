#!/usr/bin/env bash

if [ "$EUID" -eq 0 ]; then
	echo "Este script NÃO pode ser rodado como root!"
  exit 1
fi

cd ../../../preinstall
source header.sh
cd ../avapolos/resources/dependencies

LOGFILE_PATH="$compilerRoot/build.log"

echo "update.sh dependencies" | log debug

#Begin the cronometer.
start=$(date +%s)

#Clean up and update.
sudo apt-get clean  2>&1 | log debug
sudo apt-get install -f 2>&1 | log debug
sudo dpkg --configure -a 2>&1 | log debug
sudo apt-get update - 2>&1 | log debug
rm -rf *.deb
rm -rf Packages
rm -rf docker-compose

#Check if apt-rdepends is installed.
if ! [ -x "$(command -v apt-rdepends)" ]; then
	echo "$ATENCAO Instalando apt-rdepends" | log debug
	sudo apt install apt-rdepends -y 2>&1 | log debug
fi

#Setting the packages to be downloaded.
packages=$(cat packages)
echo "Baixando os seguintes pacotes e suas dependências: $packages" | log debug

for pkg in $packages; do
	apt-get download $(apt-rdepends $pkg | grep -v "^ " | grep -v debconf-2.0) 2>&1 | log debug
done

dpkg-scanpackages . /dev/null > Packages

echo "Baixando o docker-compose" | log debug
sudo curl -L "https://github.com/docker/compose/releases/download/1.24.1/docker-compose-$(uname -s)-$(uname -m)" -o ./docker-compose

#Set up the permissions.
chmod 744 -R *.deb

#Stopping the cronometer
end=$(date +%s)

#Calculating the runtime.
runtime=$((end-start))

#Let the user know it's done and the runtime.
echo "Dependências atualizadas com sucesso, em "$runtime"s." | log info
