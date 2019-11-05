#!/usr/bin/env bash

rm -rf $BASIC_DATA_DIR/*
mkdir -p $BASIC_DATA_DIR/{controle,downloads}
docker-compose down

cd scripts

run controle.sh
run downloads.sh

echo "Serviço configurado com sucesso!"
