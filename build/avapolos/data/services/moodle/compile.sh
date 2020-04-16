#!/usr/bin/env bash

log debug "Assegurando permissões corretas e limpando diretório de dados." 
sudo chown -R $USER:$USER .
rm -rf $MOODLE_DATA_DIR/*
mkdir -p $MOODLE_DATA_DIR/{moodle,db_moodle_ies,db_moodle_polo}

log debug "Parando serviços caso já estejam rodando." 
docker-compose down

cd scripts

run bdr.sh
run moodle.sh

log info "Serviço configurado com sucesso!" 
