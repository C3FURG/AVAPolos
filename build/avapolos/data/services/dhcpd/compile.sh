#!/usr/bin/env bash

log debug "Limpando diretório de dados." 
rm -rf $DHCPD_DATA_DIR/*
mkdir -p $DHCPD_DATA_DIR/dhcpd
log debug "Parando serviços caso já estejam rodando." 

cd scripts

run dhcpd.sh

log info "Serviço configurado com sucesso!" 
