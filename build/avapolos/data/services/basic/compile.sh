#!/usr/bin/env bash

echo "Assegurando permissões corretas e limpando diretório de dados." | log debug
sudo chown -R $USER:$USER .
rm -rf $BASIC_DATA_DIR/*
mkdir -p $BASIC_DATA_DIR/{controle,downloads,db_controle}

echo "Parando serviços caso já estejam rodando." | log debug data_compiler
docker-compose down

cd scripts

run db_controle.sh
run controle.sh
run downloads.sh

echo "Serviço configurado com sucesso!" | log info data_compiler
