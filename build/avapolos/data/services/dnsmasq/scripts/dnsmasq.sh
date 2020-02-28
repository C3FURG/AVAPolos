#!/usr/bin/env bash

echo "Compilando dnsmasq" | log info data_compiler

echo "Assegurando permissões corretas e limpando diretórios de dados." | log debug data_compiler
cd $DNSMASQ_DIR
sudo chown -R $USER:$USER .
sudo rm -rf $DNSMASQ_DATA_DIR/dnsmasq/*

echo "Copiando recursos do serviço." | log debug data_compiler
cp $DNSMASQ_RESOURCES_DIR/dnsmasq.conf $DNSMASQ_DATA_DIR/dnsmasq/dnsmasq.conf
