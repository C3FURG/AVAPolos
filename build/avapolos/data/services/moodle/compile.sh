#!/usr/bin/env bash

show_var PUID
show_var PGID
show_var POSTGRES_PASSWORD
show_var MOODLE_PASSWORD

echo "Removendo arquivos anteriores." | log debug data_compiler
rm -rf $MOODLE_DATA_DIR/*
mkdir -p $MOODLE_DATA_DIR/{db_moodle_ies,db_moodle_polo,moodle}
docker-compose down

cd scripts

run bdr.sh
run moodle.sh

echo "Serviço configurado com sucesso!" | log debug data_compiler
