#!/usr/bin/env bash

source /etc/avapolos/header.sh
if [[ -f $NOIP_ENV_PATH/noip.env ]]; then
  source $NOIP_ENV_PATH/noip.env
fi

DOMAIN=${DOMAIN:=avapolos}

ip=$(bash $INSTALL_SCRIPTS_PATH/get_ip.sh)

switch_name() {
  echo "Configurando para acesso com nomes." | log debug access_mode

  rm -f $DATA_PATH/inicio/public/ip
  touch $DATA_PATH/inicio/public/name

  #Change the address in Moodle's config.php
  if [[ -f $DATA_PATH/moodle/public/config.php ]]; then
    for line in $(cat $DATA_PATH/moodle/public/config.php); do
      if [[ $line =~ wwwroot ]]; then
        lineNumber=$(cat $DATA_PATH/moodle/public/config.php | grep -n "$line" | cut -d: -f1)
        newLine='$CFG->wwwroot   = "http:\/\/moodle.'$DOMAIN'";'
        sed -i "$lineNumber"'s/.*/'"$newLine"'/' $DATA_PATH/moodle/public/config.php
      fi
    done
  fi

  #Change the address in Wiki's LocalSettings.php
  if [[ -f $DATA_PATH/wiki/public/LocalSettings.php ]]; then
    for line in $(cat $DATA_PATH/wiki/public/LocalSettings.php); do
      if [[ $line =~ wgServer ]]; then
        lineNumber=$(cat $DATA_PATH/wiki/public/LocalSettings.php | grep -n "$line" | cut -d: -f1)
        newLine='$wgServer = "http:\/\/wiki.'$DOMAIN'";'
        sed -i "$lineNumber"'s/.*/'"$newLine"'/' $DATA_PATH/wiki/public/LocalSettings.php
      fi
    done
  fi

  sudo sed -i '/hub_80\.yml/d' $SERVICES_PATH/enabled_services
  echo "hub_name.yml" >> $SERVICES_PATH/enabled_services
  echo "router.yml" >> $SERVICES_PATH/enabled_services
}

switch_ip() {
  echo "Configurando para acesso com ip." | log debug access_mode

  rm -f $DATA_PATH/inicio/public/name
  touch $DATA_PATH/inicio/public/ip

  #Change the address in Moodle's config.php
  if [[ -f $DATA_PATH/moodle/public/config.php ]]; then
    for line in $(cat $DATA_PATH/moodle/public/config.php); do
      if [[ $line =~ wwwroot ]]; then
        lineNumber=$(cat $DATA_PATH/moodle/public/config.php | grep -n "$line" | cut -d: -f1)
        newLine='$CFG->wwwroot   = "http:\/\/'$ip':81";'
        sed -i "$lineNumber"'s/.*/'"$newLine"'/' $DATA_PATH/moodle/public/config.php
      fi
    done
  fi

  #Change the address in Wiki's LocalSettings.php
  if [[ -f $DATA_PATH/wiki/public/LocalSettings.php ]]; then
    for line in $(cat $DATA_PATH/wiki/public/LocalSettings.php); do
      if [[ $line =~ wgServer ]]; then
        lineNumber=$(cat $DATA_PATH/wiki/public/LocalSettings.php | grep -n "$line" | cut -d: -f1)
        newLine='$wgServer = "http:\/\/'$ip':82";'
        sed -i "$lineNumber"'s/.*/'"$newLine"'/' $DATA_PATH/wiki/public/LocalSettings.php
      fi
    done
  fi

  sudo sed -i '/hub_name\.yml/d' $SERVICES_PATH/enabled_services
  sudo sed -i '/router\.yml/d' $SERVICES_PATH/enabled_services
  echo "hub_80.yml" >> $SERVICES_PATH/enabled_services
}

update_ip() {
  sed -i 's/{IP}/'$ip'/' $DATA_PATH/inicio/public/index.php
  sed -ri 's/([0-9]{1,3}\.){3}[0-9]{1,3}/'$ip'/' $DATA_PATH/inicio/public/index.php
}

case "$1" in
  name )
    stop
    switch_name
    echo "Configuração executada com sucesso, iniciando serviços." | log info access_mode
    start
    ;;
  ip )
    stop
    switch_ip
    echo "Configuração executada com sucesso, iniciando serviços." | log info access_mode
    start
    ;;

  * )
    echo "Argumento incorreto.." | log error access_mode
    ;;
esac
