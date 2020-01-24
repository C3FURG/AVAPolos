#!/usr/bin/env bash

source /etc/avapolos/header.sh

echo "dyndns.sh" | log debug dynDns

add_service noip.yml
enable_service noip.yml

echo "NO-IP habilitado" | log debug dynDns
