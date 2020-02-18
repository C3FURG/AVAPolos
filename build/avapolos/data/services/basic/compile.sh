#!/usr/bin/env bash

echo "Limpando diretório de dados." | log debug data_compiler
rm -rf $BASIC_DATA_DIR/*
mkdir -p $BASIC_DATA_DIR/{controle,downloads}
echo "Parando serviços caso já estejam rodando." | log debug data_compiler
docker-compose down

cd scripts

run db_controle.sh
run controle.sh
run downloads.sh

echo "Serviço configurado com sucesso!" | log info data_compiler
