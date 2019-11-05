#!/usr/bin/env bash

cd $BASIC_DIR
sudo chown -R $USER:$USER .
sudo rm -rf $BASIC_DATA_DIR/controle/*
mkdir -p $BASIC_DATA_DIR/controle/public

cp -rf $BASIC_RESOURCES_DIR/controle/public $BASIC_DATA_DIR/controle
mkdir -p $BASIC_DATA_DIR/controle/public/vendor/{fontawesome-free,jquery}

tmp=$(mktemp -d -t controle_vendor_download.XXXXXXX)
wget -O $tmp/fontawesome-free.zip https://use.fontawesome.com/releases/v5.11.2/fontawesome-free-5.11.2-web.zip
cd $tmp
unzip fontawesome-free.zip
cd $BASIC_DIR
cp -rf $tmp/fontawesome-free-5.11.2-web/* $BASIC_DATA_DIR/controle/public/vendor/fontawesome-free/

wget -O  $BASIC_DATA_DIR/controle/public/vendor/jquery/jquery.min.js https://code.jquery.com/jquery-3.4.1.min.js

echo "Iniciando webserver"
docker-compose up -d controle

testURL "http://controle.avapolos"

rm -rf $tmp
