#!/usr/bin/env bash

#If root, exit.
if [ "$EUID" = "0" ]; then
    echo "Este script não pode ser rodado como root."
    exit
fi

cd ../../preinstall
source header.sh
cd ../avapolos/resources

#Begin the cronometer.
start=$(date +%s)

echo "update_resources.sh" | log debug
echo "Iniciando atualização das dependências." | log info

#If we dont detect internet, exit.
command=$(ping -4 -c 3 www.google.com)
if [ $? -ne 0 ]; then
  echo "Atualização cancelada, host offline." | log error
  exit 1
else
	echo "Internet detectada" | log debug
fi

cd $installRoot/resources

if [ "$update" = "y" ]; then

  if [ "$update_deps" = "y" ]; then

    if [ -z "$(find /etc/apt/ -name *.list | xargs cat | grep '^[[:space:]]*deb' | grep docker)" ]; then
      echo "Adicionando repositório do Docker" | log debug
      curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
      sudo add-apt-repository \
      "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) \
      stable"
    fi
    cd dependencies
    bash update.sh
  fi

  if [ "$update_images" = "y" ]; then
    cd $installRoot/resources/docker_images
    sudo bash update.sh
  fi

else
  echo "Atualização cancelada pelo usuário." | log warn
fi

#Stopping the cronometer
end=$(date +%s)

#Calculating the runtime.
runtime=$((end-start))

echo "Atualização dos recursos completa em "$runtime"s." | log info
