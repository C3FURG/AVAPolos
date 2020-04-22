#!/usr/bin/env bash

log debug "Limpando diretório de dados." 
rm -rf $DNSMASQ_DATA_DIR/*
mkdir -p $DNSMASQ_DATA_DIR/dnsmasq
log debug "Parando serviços caso já estejam rodando." 

cd scripts

run dnsmasq.sh

log info "Serviço configurado com sucesso!" 
