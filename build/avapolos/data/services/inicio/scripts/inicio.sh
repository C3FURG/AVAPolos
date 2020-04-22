#!/usr/bin/env bash

log info "Compilando inicio.avapolos" 

log debug "Assegurando permissões corretas e limpando diretórios de dados." 
cd $INICIO_DIR
sudo chown -R $USER:$USER .
sudo rm -rf $INICO_DATA_DIR/inicio/*
mkdir -p $BASIC_DATA_DIR/inicio/public

log debug "Copiando recursos do serviço." 
cp -rf $INICIO_RESOURCES_DIR/public $INICIO_DATA_DIR/inicio/

log debug "Iniciando webserver" 
docker-compose up -d

sleep 3
testURL "http://inicio.avapolos"
