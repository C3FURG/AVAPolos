#!/usr/bin/env bash

show_var PUID
show_var PGID
#Here you can show variables defined in header.sh
show_var SERVICE_PASSWORD

mkdir -p $SERVICE_DATA_DIR/{dir1,dir2}
docker-compose down

cd scripts

run compile1.sh
run compile2.sh

#cp -rf data/* ../../temp
