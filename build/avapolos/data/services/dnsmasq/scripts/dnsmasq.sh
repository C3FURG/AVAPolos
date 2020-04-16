#!/usr/bin/env bash

log info "Compilando dnsmasq" 

log debug "Assegurando permissões corretas e limpando diretórios de dados." 
cd $DNSMASQ_DIR
sudo chown -R $USER:$USER .
sudo rm -rf $DNSMASQ_DATA_DIR/dnsmasq/*

log debug "Copiando recursos do serviço." 
cp $DNSMASQ_RESOURCES_DIR/dnsmasq.conf $DNSMASQ_DATA_DIR/dnsmasq/dnsmasq.conf
