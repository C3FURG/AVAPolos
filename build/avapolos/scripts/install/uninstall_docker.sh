#!/usr/bin/env bash

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

echo "uninstall_docker.sh" | log debug
echo "Desinstalando Docker." | log info

docker ps > /dev/null 2>&1

if [ "$?" = "0" ]; then
  containers=$(docker ps -aq --no-trunc)
  if ! [ -z "$containers" ]; then
    echo "Existem containers ativos que não pertencem ao avapolos!" | log warn
    input "Deseja cancelar a instalação para encerrá-los manualmente? (Serão terminados automaticamente caso digite 'nao')" "sim" "nao" 0 "Você precisa selecionar uma opção!"
    if [ "$option" = "sim" ]; then
      echo "Cancelando desinstalação do Docker." | log error
      exit 1;
    else
      for container in $containers; do
        echo "parando: $(docker container stop $container)" | log debug
        echo "removendo: $(docker container rm $container)" | log debug
      done
    fi
  fi
fi

if [ -x "$(command -v docker)" ]; then
  echo "Desinstalando Docker." | log info

  #Stop the services.
  sudo systemctl stop docker.service
  sudo systemctl stop containerd.service

  #Wait for dpkg/lock.
  while fuser /var/lib/dpkg/lock >/dev/null 2>&1 ; do
      echo "O dpkg está ocupado, esperando..." | log info
      sleep 3
  done

  #Try to fix broken packages.
  sudo apt-get --fix-broken install -y

  #Purge packages.
  sudo apt-get purge -y docker-engine docker docker.io docker-ce docker-ce-cli containerd.io
  sudo apt-get autoremove -y --purge docker-engine docker docker.io docker-ce docker-ce-cli containerd.io

  if [ "$INTERACTIVE" = "y" ]; then
    input "Deseja remover os arquivos do Docker? (Recomendado)" "sim" "nao" 0 "Selecione uma opção."

    if [ "$option" = "sim" ]; then
      echo "Removendo arquivos do Docker." | log debug
      sudo rm -rf /var/lib/docker
  	  sudo rm -f /etc/apparmor.d/docker
    fi
  else
    echo "Removendo arquivos do Docker." | log debug
    sudo rm -rf /var/lib/docker
    sudo rm -f /etc/apparmor.d/docker
  fi

  if [ -x "$(command -v docker)" ]; then
    echo "Ocorreu um erro na desinstalação do Docker, tente novamente." | log error
    exit 1
  else
    echo "Docker desinstalado com sucesso."
  fi
else
  echo "Docker já está desinstalado!" | log warn
fi

echo "Removendo docker-compose" | log debug
sudo rm -rf /usr/local/bin/docker-compose
