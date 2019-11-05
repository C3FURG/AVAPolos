#!/usr/bin/env bash

cd $SERVICE_DIR

sudo chown -R $USER:$USER .

echo "Iniciando service"
docker-compose up -d

sleep 3

testURL "service.avapolos"
