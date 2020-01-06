#!/usr/bin/env bash

source /etc/avapolos/header.sh

echo "dyndns.sh" | log debug

echo "Iniciando serviço de DNS dinâmico, responda às perguntas corretamente!" | log info

docker run -it --rm -v $RESOURCES_PATH:/usr/local/etc romeupalos/noip -C

add_service noip.yml
enable_service noip.yml
