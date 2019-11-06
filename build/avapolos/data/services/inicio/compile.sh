#!/usr/bin/env bash

echo "Limpando diretório de dados." | log debug data_compiler
rm -rf $INICIO_DATA_DIR/*
mkdir -p $INICIO_DATA_DIR/inicio
echo "Parando serviços caso já estejam rodando." | log debug data_compiler
docker-compose down

cd scripts

run inicio.sh

echo "Serviço configurado com sucesso!" | log info data_compiler
