#!/usr/bin/env bash

log info "Compilando traefik.avapolos" 

log debug "Assegurando permissões corretas e limpando diretórios de dados." 
cd $TRAEFIK_DIR
sudo chown -R $USER:$USER .
sudo rm -rf $TRAEFIK_DATA_DIR/traefik/*

log debug "Copiando recursos do serviço." 
cp $TRAEFIK_RESOURCES_DIR/traefik.toml $TRAEFIK_DATA_DIR/traefik/

log debug "Iniciando traefik" 
docker-compose up -d

sleep 3
testURL "http://traefik.avapolos"
