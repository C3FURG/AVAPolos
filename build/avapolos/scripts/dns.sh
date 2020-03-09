#!/usr/bin/env bash

source /etc/avapolos/header.sh
source $SYNC_PATH/variables.sh
source $SYNC_PATH/functions.sh

case $1 in
  enable )
    stop
    add_service dnsmasq.yml
    enable_service dnsmasq.yml
    run $SCRIPTS_PATH/update_dns.sh 10.254.0.1
    start
    ;;
  disable )
    stop
    disable_service dnsmasq.yml
    run $SCRIPTS_PATH/update_dns.sh 1.1.1.1 1.0.0.1
    start
esac
