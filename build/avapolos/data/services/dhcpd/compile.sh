#!/usr/bin/env bash

echo "Limpando diretório de dados." | log debug data_compiler
rm -rf $DHCPD_DATA_DIR/*
mkdir -p $DHCPD_DATA_DIR/dhcpd
echo "Parando serviços caso já estejam rodando." | log debug data_compiler

cd scripts

run dhcpd.sh

echo "Serviço configurado com sucesso!" | log info data_compiler
