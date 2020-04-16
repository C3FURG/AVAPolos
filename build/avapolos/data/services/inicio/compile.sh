#!/usr/bin/env bash

log debug "Limpando diretório de dados." 
rm -rf $INICIO_DATA_DIR/*
mkdir -p $INICIO_DATA_DIR/inicio
log debug "Parando serviços caso já estejam rodando." 
docker-compose down

cd scripts

run inicio.sh

log info "Serviço configurado com sucesso!" 
