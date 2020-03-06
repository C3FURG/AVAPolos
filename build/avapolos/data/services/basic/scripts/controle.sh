#!/usr/bin/env bash

echo "Compilando controle.avapolos" | log info data_compiler

echo "Assegurando permissões corretas e limpando diretórios de dados." | log debug data_compiler
cd $BASIC_DIR
sudo chown -R $USER:$USER .
sudo rm -rf $BASIC_DATA_DIR/controle/*
mkdir -p $BASIC_DATA_DIR/controle/public


echo "Copiando recursos do serviço." | log debug data_compiler
cp -rf $BASIC_RESOURCES_DIR/controle/public $BASIC_DATA_DIR/controle
envsubst $BASIC_DATA_DIR/controle/public/config.php

echo "Iniciando webserver" | log debug data_compiler
docker-compose up -d controle

testURL "http://controle.avapolos" | log debug data_compiler

echo "Excluindo diretório temporário." | log debug data_compiler
rm -rf $tmp
