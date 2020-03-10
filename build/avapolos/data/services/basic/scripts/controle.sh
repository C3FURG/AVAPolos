#!/usr/bin/env bash

echo "Compilando controle.avapolos" | log info data_compiler

mkdir -p $BASIC_DATA_DIR/controle/public

echo "Copiando recursos do serviço." | log debug data_compiler
cp -rf $BASIC_RESOURCES_DIR/controle/public $BASIC_DATA_DIR/controle
envsubst '$DB_CONTROLE_AVAPOLOS_PASSWORD' < $BASIC_DATA_DIR/controle/public/config.php.dist > $BASIC_DATA_DIR/controle/public/config.php

echo "Iniciando webserver" | log debug data_compiler
docker-compose up -d controle

testURL "http://controle.avapolos" | log debug data_compiler
