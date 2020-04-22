#!/usr/bin/env bash

log debug "Assegurando permissões corretas e limpando diretório de dados." 
sudo chown -R $USER:$USER .
rm -rf $WIKI_DATA_DIR/*
mkdir -p $WIKI_DATA_DIR/{db_wiki,wiki}

log debug "Parando serviços caso já estejam rodando." 
docker-compose down

cd scripts

run db.sh
run wiki.sh

log info "Serviço configurado com sucesso!" 
