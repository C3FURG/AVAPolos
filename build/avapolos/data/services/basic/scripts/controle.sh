#!/usr/bin/env bash

log info "Compilando controle.avapolos" 

mkdir -p $BASIC_DATA_DIR/controle/public

log debug "Copiando recursos do serviço." 
cp -rf $BASIC_RESOURCES_DIR/controle/public $BASIC_DATA_DIR/controle
envsubst '$DB_CONTROLE_AVAPOLOS_PASSWORD' < $BASIC_DATA_DIR/controle/public/config.php.dist > $BASIC_DATA_DIR/controle/public/config.php

log debug "Iniciando webserver" 
docker-compose up -d controle

testURL "http://controle.avapolos"
