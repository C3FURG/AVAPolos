#!/usr/bin/env bash

echo "Limpando diretório de dados." | log debug data_compiler
rm -rf $TRAEFIK_DATA_DIR/*
mkdir -p $TRAEFIK_DATA_DIR/traefik
echo "Parando serviços caso já estejam rodando." | log debug data_compiler
docker-compose down

cd scripts

run traefik.sh

echo "Serviço configurado com sucesso!"
