#!/usr/bin/env bash

log info "Compilando dhcpd" 

log debug "Assegurando permissões corretas e limpando diretórios de dados." 
cd $DHCPD_DIR
sudo chown -R $USER:$USER .
sudo rm -rf $DHCPD_DATA_DIR/dhcpd/*

log debug "Copiando recursos do serviço." 
cp $DHCPD_RESOURCES_DIR/dhcpd.conf $DHCPD_DATA_DIR/dhcpd/dhcpd.conf
