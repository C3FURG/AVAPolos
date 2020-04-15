#!/usr/bin/env bash

log debug "update.sh docker_images"

if ! [ -f "images" ]; then
  log error "Arquivo images não encontrado!"
  exit 1
fi

#Begin the cronometer.
start=$(date +%s)

#Setting the images to be downloaded
#images="avapolos/postgres:bdr avapolos/webserver:lite avapolos/dnsmasq:latest library/traefik avapolos/backup:stable portainer/portainer"
#brendowdf/dpsace-educapes:latest brendowdf/dspace-postgres-educapes:latest
images=$(cat images)

log debug "Atualizando imagens: ${images[@]}"

rm -f *.tar

#For every image, download it.
for img in $images; do

  firstName=$(echo $img | cut -d"/" -f2 | cut -d":" -f1)
  lastName=$(echo $img | cut -d"/" -f2 | cut -d":" -f2)
  imgFileName=$(echo $firstName"_"$lastName".tar")

  log debug "Checando imagem: $img"
  docker pull $img || exit 1

  docker save -o $imgFileName $img || exit 1

done

#Stop the cronometer
end=$(date +%s)

#Calculating the runtime.
runtime=$((end-start))

#Let the user know it's done and the runtime
log info "Imagens atualizadas com sucesso, em "$runtime"s."
