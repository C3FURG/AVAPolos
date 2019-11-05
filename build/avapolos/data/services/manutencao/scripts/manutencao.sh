#!/usr/bin/env bash

cd $MANUTENCAO_DIR

sudo chown -R $USER:$USER .

cp -rf $MANUTENCAO_RESOURCES_DIR/public $MANUTENCAO_DATA_DIR/manutencao

echo "Iniciando manutencao"
docker-compose up -d

sleep 3

echo "Manutencao configurado com sucesso!"
