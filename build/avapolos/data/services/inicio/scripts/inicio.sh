#!/usr/bin/env bash

echo "Compilando inicio.avapolos" | log info data_compiler

echo "Assegurando permissões corretas e limpando diretórios de dados." | log debug data_compiler
cd $INICIO_DIR
sudo chown -R $USER:$USER .
sudo rm -rf $INICO_DATA_DIR/inicio/*
mkdir -p $BASIC_DATA_DIR/inicio/public

echo "Copiando recursos do serviço." | log debug data_compiler
cp -rf $INICIO_RESOURCES_DIR/public $INICIO_DATA_DIR/inicio/

echo "Iniciando webserver" | log debug data_compiler
docker-compose up -d

testURL "inicio.avapolos" | log debug data_compiler
