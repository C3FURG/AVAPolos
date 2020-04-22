#!/usr/bin/env bash

log debug "Assegurando permissões corretas e limpando diretório de dados." 
sudo chown -R $USER:$USER .
rm -rf $BASIC_DATA_DIR/*
mkdir -p $BASIC_DATA_DIR/{controle,downloads,db_controle}

log debug "Parando serviços caso já estejam rodando." 
docker-compose down

cd scripts

run db_controle.sh
run controle.sh
run downloads.sh

log info "Serviço configurado com sucesso!" 
