#!/usr/bin/env bash

source /etc/avapolos/header.sh

$MOODLE_URL="moodle.avapolos"
$MOODLE_PORT="81"

$WIKI_URL="wiki.avapolos"
$WIKI_PORT="82"

$EDUCAPES_URL="educapes.avapolos/jspui"
$EDUCAPES_PORT="83"

$DOWNLOADS_URL="downloads.avapolos"
$DOWNLOADS_PORT="84"

ip=$(bash $INSTALL_SCRIPTS_PATH/get_ip.sh)

if [ $1 = "name" ]; then
  stop
  echo "Configurando o servidor para utilizar nomes." | log info access_mode



  str="$ip:81"
  sed -i "s/"$str"/moodle.avapolos/g" $DATA_PATH/moodle/public/config.php
  sed -i "s/"$str"/moodle.avapolos/g" $DATA_PATH/hub/public/index.html

  str="$ip:82"
  sed -i "s/"$str"/wiki.avapolos/g" $DATA_PATH/wiki/public/LocalSettings.php
  sed -i "s/"$str"/wiki.avapolos/g" $DATA_PATH/hub/public/index.html

  str="$ip:83\/jspui"
  sed -i "s/"$str"/educapes.avapolos\/jspui/g" $DATA_PATH/hub/public/index.html

  str="$ip:84"
  sed -i "s/"$str"/downloads.avapolos/g" $DATA_PATH/downloads/public/index.html
  sed -i "s/"$str"/downloads.avapolos/g" $DATA_PATH/hub/public/index.html

  sudo sed -i '/hub_80\.yml/d' $SERVICES_PATH/enabled_services
  echo "hub_name.yml" >> $SERVICES_PATH/enabled_services
  echo "router.yml" >> $SERVICES_PATH/enabled_services

  echo "Configuração executada com sucesso, iniciando serviços." | log info access_mode

  start
elif [ $1 = "ip" ]; then
  stop


  echo "Configurando o servidor para utilizar IPs e portas." | log info access_mode

  sed -i "s/moodle.avapolos/"$ip":81""/g" $DATA_PATH/moodle/public/config.php
  sed -i "s/moodle.avapolos/"$ip":81/g" $DATA_PATH/hub/public/index.html

  sed -i "s/wiki.avapolos/"$ip":82/g" $DATA_PATH/wiki/public/LocalSettings.php
  sed -i "s/wiki.avapolos/"$ip":82/g" $DATA_PATH/hub/public/index.html

  sed -i "s/educapes.avapolos\/jspui/"$ip":83\/jspui/g" $DATA_PATH/hub/public/index.html

  sed -i "s/downloads.avapolos/"$ip":84/g" $DATA_PATH/downloads/public/index.html
  sed -i "s/downloads.avapolos/"$ip":84/g" $DATA_PATH/hub/public/index.html

  sudo sed -i '/hub_name\.yml/d' $SERVICES_PATH/enabled_services
  sudo sed -i '/router\.yml/d' $SERVICES_PATH/enabled_services
  echo "hub_80.yml" >> $SERVICES_PATH/enabled_services

  echo "Configuração executada com sucesso, iniciando serviços." | log info access_mode

  start
else
  echo "Uso: switch.sh [name/ip]"
fi
