#!/usr/bin/env bash

log debug "Limpando diretório de dados." 
rm -rf $MANUTENCAO_DATA_DIR/*
mkdir -p $MANUTENCAO_DATA_DIR/manutencao
log debug "Parando serviços caso já estejam rodando." 
docker-compose down

cd scripts

run manutencao.sh

log info "Serviço configurado com sucesso!" 
