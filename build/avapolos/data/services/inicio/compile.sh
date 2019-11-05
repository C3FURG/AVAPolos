#!/usr/bin/env bash

show_var PUID
show_var PGID

rm -rf $INICIO_DATA_DIR/*
mkdir -p $INICIO_DATA_DIR/inicio
docker-compose down

cd scripts

run inicio.sh

echo "Serviço configurado com sucesso!"
