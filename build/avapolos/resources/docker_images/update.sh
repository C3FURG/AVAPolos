#!/usr/bin/env bash

cd ../../../preinstall
source header.sh
cd ../avapolos/resources/docker_images

LOGFILE_PATH="$compilerRoot/build.log"

echo "update.sh docker_images" | log debug

if ! [ -f "images" ]; then
  echo "Arquivo images não encontrado!" | log error
  exit 1
fi

#Begin the cronometer.
start=$(date +%s)

#Setting the images to be downloaded
#images="avapolos/postgres:bdr avapolos/webserver:lite avapolos/dnsmasq:latest library/traefik avapolos/backup:stable portainer/portainer"
#brendowdf/dpsace-educapes:latest brendowdf/dspace-postgres-educapes:latest
images=$(cat images)

echo "images to check: ${images[@]}" | log debug

rm -f *.tar

pwd=$PWD

#For every image, download it.
for img in $images; do

  firstName=$(echo $img | cut -d"/" -f2 | cut -d":" -f1)
  lastName=$(echo $img | cut -d"/" -f2 | cut -d":" -f2)
  imgFileName=$(echo $firstName"_"$lastName".tar")

  echo "Checando imagem: $img" | log debug
  docker pull $img | log debug

  docker save -o $imgFileName $img

done

#Stop the cronometer
end=$(date +%s)

#Calculating the runtime.
runtime=$((end-start))

#Let the user know it's done and the runtime
echo "Imagens atualizadas com sucesso, em "$runtime"s." | log info
