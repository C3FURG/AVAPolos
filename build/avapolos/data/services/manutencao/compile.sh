#!/usr/bin/env bash

show_var PUID
show_var PGID

rm -rf $MANUTENCAO_DATA_DIR/*
mkdir -p $MANUTENCAO_DATA_DIR/manutencao
docker-compose down

cd scripts

run manutencao.sh

echo "Serviço configurado com sucesso!"
