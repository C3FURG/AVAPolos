#!/usr/bin/env bash

echo "Limpando diretório de dados." | log debug data_compiler
rm -rf $DNSMASQ_DATA_DIR/*
mkdir -p $DNSMASQ_DATA_DIR/dnsmasq
echo "Parando serviços caso já estejam rodando." | log debug data_compiler

cd scripts

run dnsmasq.sh

echo "Serviço configurado com sucesso!" | log info data_compiler
