#!/usr/bin/env bash

echo "Assegurando permissões corretas e limpando diretório de dados." | log debug
sudo chown -R $USER:$USER .
rm -rf $WIKI_DATA_DIR/*
mkdir -p $WIKI_DATA_DIR/{db_wiki,wiki}

echo "Parando serviços caso já estejam rodando." | log debug data_compiler
docker-compose down

cd scripts

run db.sh
run wiki.sh

echo "Serviço configurado com sucesso!" | log info data_compiler
