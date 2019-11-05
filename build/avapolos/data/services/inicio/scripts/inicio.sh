#!/usr/bin/env bash

cd $INICIO_DIR

sudo chown -R $USER:$USER .

cp -rf $INICIO_RESOURCES_DIR/public $INICIO_DATA_DIR/inicio/

echo "Iniciando inicio"
docker-compose up -d

sleep 3

testURL "inicio.avapolos"
