#!/usr/bin/env bash

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

log debug "uninstall_docker.sh" 
log info "Desinstalando Docker." 

docker ps > /dev/null 2>&1

if [ "$?" = "0" ]; then
  containers=$(docker ps -aq --no-trunc)
  if ! [ -z "$containers" ]; then
    log warn "Existem containers ativos que não pertencem ao avapolos!" 
    input "Deseja cancelar a instalação para encerrá-los manualmente? (Serão terminados automaticamente caso digite 'nao')" "sim" "nao" 0 "Você precisa selecionar uma opção!"
    if [ "$option" = "sim" ]; then
      log error "Cancelando desinstalação do Docker." 
      exit 1;
    else
      for container in $containers; do
        log debug "parando: $(docker container stop $container)"
        log debug "removendo: $(docker container rm $container)" 
      done
    fi
  fi
fi

if [ -x "$(command -v docker)" ]; then
  log info "Desinstalando Docker." 

  #Stop the services.
  sudo systemctl stop docker.service
  sudo systemctl stop containerd.service

  #Wait for dpkg/lock.
  while fuser /var/lib/dpkg/lock >/dev/null 2>&1 ; do
    log info "O dpkg está ocupado, esperando..." 
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
log debug  "Removendo arquivos do Docker." 
      sudo rm -rf /var/lib/docker
  	  sudo rm -f /etc/apparmor.d/docker
    fi
  else
log debug  "Removendo arquivos do Docker." 
    sudo rm -rf /var/lib/docker
    sudo rm -f /etc/apparmor.d/docker
  fi

  if [ -x "$(command -v docker)" ]; then
log error  "Ocorreu um erro na desinstalação do Docker, tente novamente." 
    exit 1
  else
    echo "Docker desinstalado com sucesso."
  fi
else
log warn  "Docker já está desinstalado!" 
fi

log debug  "Removendo docker-compose" 
sudo rm -rf /usr/local/bin/docker-compose
