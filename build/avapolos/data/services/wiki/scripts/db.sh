#!/usr/bin/env bash

cd $WIKI_DIR

echo "Removendo arquivos anteriores."
sudo rm -rf $WIKI_DATA_DIR/db_wiki/*

docker-compose up -d db_wiki

waitForHealthy db_wiki

echo "Configurando base de dados db_wiki."
execSQL db_wiki "
  CREATE DATABASE wiki;
";

execSQL db_wiki "
  CREATE ROLE wiki;
  ALTER USER wiki WITH LOGIN PASSWORD '@bancoava.C4p35*&';
  GRANT ALL PRIVILEGES ON DATABASE wiki TO wiki;
";

echo "Base configurada com sucesso!"
