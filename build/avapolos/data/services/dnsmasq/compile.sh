#!/usr/bin/env bash

show_var PUID
show_var PGID

mkdir -p $SERVICE_DATA_DIR/{dir1,dir2}

cd scripts

run dnsmasq.sh
