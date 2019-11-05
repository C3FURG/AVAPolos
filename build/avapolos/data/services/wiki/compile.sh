#!/usr/bin/env bash

show_var WIKI_PASSWORD

docker-compose down

rm -rf $WIKI_DATA_DIR/*
mkdir -p $WIKI_DATA_DIR/{db_wiki,wiki}

cd scripts

run db.sh
run wiki.sh

echo "Serviço configurado com sucesso!"
