#!/usr/bin/env bash

cd $TRAEFIK_DIR

cp $TRAEFIK_RESOURCES_DIR/traefik.toml $TRAEFIK_DATA_DIR/traefik/
sudo chown -R $USER:$USER .

echo "Iniciando traefik"
docker-compose up -d

sleep 3

testURL "traefik.avapolos"
