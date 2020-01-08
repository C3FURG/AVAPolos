#!/usr/bin/env bash

source /etc/avapolos/header.sh

echo "dyndns.sh" | log debug dynDns

echo "Iniciando serviço de DNS dinâmico, responda às perguntas corretamente!" | log info dynDns

docker run -it --rm -v $RESOURCES_PATH:/usr/local/etc coppit/noip -C

add_service noip.yml
enable_service noip.yml
