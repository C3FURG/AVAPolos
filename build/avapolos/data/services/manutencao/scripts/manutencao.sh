#!/usr/bin/env bash

log info "Compilando placeholder para manutencoes" 

log debug "Assegurando permissões corretas e limpando diretórios de dados." 
cd $MANUTENCAO_DIR
sudo chown -R $USER:$USER .
sudo rm -rf $MANUTENCAO_DATA_DIR/manutencao/*
mkdir -p $MANUTENCAO_DATA_DIR/manutencao/public

log debug "Copiando recursos do serviço." 
cp -rf $MANUTENCAO_RESOURCES_DIR/public $MANUTENCAO_DATA_DIR/manutencao

log debug "Iniciando webserver" 
docker-compose up -d

testURL "http://manutencao.avapolos"
log debug "Manutencao configurado com sucesso!" 
