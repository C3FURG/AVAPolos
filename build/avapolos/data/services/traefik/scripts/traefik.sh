#!/usr/bin/env bash

echo "Compilando traefik.avapolos" | log info data_compiler

echo "Assegurando permissões corretas e limpando diretórios de dados." | log debug data_compiler
cd $TRAEFIK_DIR
sudo chown -R $USER:$USER .
sudo rm -rf $TRAEFIK_DATA_DIR/traefik/*

echo "Copiando recursos do serviço." | log debug data_compiler
cp $TRAEFIK_RESOURCES_DIR/traefik.toml $TRAEFIK_DATA_DIR/traefik/

echo "Iniciando traefik" | log debug data_compiler
docker-compose up -d

sleep 3
testURL "http://traefik.avapolos" | log debug data_compiler
