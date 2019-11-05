#!/usr/bin/env bash

echo "Removendo arquivos anteriores."
rm -rf $TRAEFIK_DATA_DIR/*
mkdir -p $TRAEFIK_DATA_DIR/traefik
docker-compose down

cd scripts

run traefik.sh

echo "Serviço configurado com sucesso!"
