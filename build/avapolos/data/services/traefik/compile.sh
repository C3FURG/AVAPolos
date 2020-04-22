#!/usr/bin/env bash

log debug "Limpando diretório de dados." 
rm -rf $TRAEFIK_DATA_DIR/*
mkdir -p $TRAEFIK_DATA_DIR/traefik
log debug "Parando serviços caso já estejam rodando." 
docker-compose down

cd scripts

run traefik.sh

echo "Serviço configurado com sucesso!"
