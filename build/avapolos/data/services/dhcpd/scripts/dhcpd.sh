#!/usr/bin/env bash

echo "Compilando dhcpd" | log info data_compiler

echo "Assegurando permissões corretas e limpando diretórios de dados." | log debug data_compiler
cd $DHCPD_DIR
sudo chown -R $USER:$USER .
sudo rm -rf $DHCPD_DATA_DIR/dhcpd/*

echo "Copiando recursos do serviço." | log debug data_compiler
cp $DHCPD_RESOURCES_DIR/dhcpd.conf $DHCPD_DATA_DIR/dhcpd/dhcpd.conf
