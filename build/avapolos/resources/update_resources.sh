#!/usr/bin/env bash

#If root, exit.
if [ "$EUID" = "0" ]; then
    echo "Este script não pode ser rodado como root."
    exit
fi

#Begin the cronometer.
start=$(date +%s)

log debug "update_resources.sh"
log info "Iniciando atualização das dependências."

#If we dont detect internet, exit.
command=$(ping -4 -c 3 www.google.com)
if [ $? -ne 0 ]; then
  log error "Atualização cancelada, host offline."
  exit 1
fi

if [ "$update" = "y" ]; then

  if [ "$update_deps" = "y" ]; then
    cd dependencies
    bash update.sh
  fi

  if [ "$update_images" = "y" ]; then
    cd ../docker_images
    sudo bash update.sh
  fi
fi

#Stopping the cronometer
end=$(date +%s)

#Calculating the runtime.
runtime=$((end-start))

log info "Atualização dos recursos completa em "$runtime"s."
