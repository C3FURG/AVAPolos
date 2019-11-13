#!/usr/bin/env bash

echo "Compilando placeholder para manutencoes" | log info data_compiler

echo "Assegurando permissões corretas e limpando diretórios de dados." | log debug data_compiler
cd $MANUTENCAO_DIR
sudo chown -R $USER:$USER .
sudo rm -rf $MANUTENCAO_DATA_DIR/manutencao/*
mkdir -p $MANUTENCAO_DATA_DIR/manutencao/public

echo "Copiando recursos do serviço." | log debug data_compiler
cp -rf $MANUTENCAO_RESOURCES_DIR/public $MANUTENCAO_DATA_DIR/manutencao

echo "Iniciando webserver" | log debug data_compiler
docker-compose up -d

testURL "http://manutencao.avapolos" | log debug data_compiler
echo "Manutencao configurado com sucesso!" | log debug data_compiler
