#!/usr/bin/env bash

echo "Assegurando permissões corretas e limpando diretório de dados." | log debug
sudo chown -R $USER:$USER .
rm -rf $MOODLE_DATA_DIR/*
mkdir -p $MOODLE_DATA_DIR/{moodle,db_moodle_ies,db_moodle_polo}

echo "Parando serviços caso já estejam rodando." | log debug data_compiler
docker-compose down

cd scripts

run bdr.sh
run moodle.sh

echo "Serviço configurado com sucesso!" | log info data_compiler
