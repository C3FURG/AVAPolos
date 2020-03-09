#!/usr/bin/env bash

source /etc/avapolos/header.sh
source $SYNC_PATH/variables.sh
source $SYNC_PATH/functions.sh

case $1 in
  enable )
    stop
    add_service dhcpd.yml
    enable_service dhcpd.yml
    run $SCRIPTS_PATH/update_network.sh 10.254.0.1 10.254.0.1 255.255.0.0 10.254.0.1 1.1.1.1
    start
    ;;
  disable )
    stop
    disable_service dhcpd.yml
    start
esac
