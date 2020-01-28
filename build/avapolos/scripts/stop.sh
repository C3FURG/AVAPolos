#!/usr/bin/env bash

source /etc/avapolos/header.sh

if [ -f $SCRIPTS_PATH/startstop.lock ]; then
  echo "Já existe um processo utilizando esse script!" | log error stop
else

  touch $SCRIPTS_PATH/startstop.lock

  cd $SERVICES_PATH

  if ! [ -f "enabled_services" ]; then
    echo "Arquivo enabled_services não encontrado!" | log error stop
    exit 1
  fi

  PUID=$(id -u avapolos)
  PGID=$(id -g avapolos)
  services=""
  specified="false"
  export PUID
  export PGID
  export COMPOSE_IGNORE_ORPHANS=1
  export EDUCAPES_PATH
  export SERVICE_PATH
  export LOG_PATH
  export MANUTENCAO=""
  export BACKUPS_PATH

  if ! [ -z "$1" ]; then
    arg=$1
    services="$arg"
    specified="true"
  else
    services=$(cat enabled_services)
  fi

  for service in $services; do
    if [ -z "$(cat stopped_services | grep -o $service)" ]; then
      echo "Parando serviço: $service" | log info stop
      docker-compose -p avapolos -f $service down | log debug stop
      echo $service >> stopped_services
      sed -i '/'"$(sanitize $service)"'/d' started_services
    else
      echo "Ignorando serviço $service..." | log info stop
    fi
  done

  if ! [ -z "$(cat started_services)" ]; then
    echo "Atualizando a página de manutenção" | log debug stop
    unset MANUTENCAO
    for service in $(cat stopped_services); do
      rule="$(cat $service | grep traefik.frontend.rule=Host: | cut -d: -f2 | cut -d\" -f1)"
      MANUTENCAO+=" $rule"
    done
    MANUTENCAO=$(echo $MANUTENCAO | sed 's/\ /\,/g')
    export MANUTENCAO
    if ! [ "$specified" = "false" ]; then
      docker-compose -p avapolos -f manutencao.yml down  | log debug stop
      docker-compose -p avapolos -f manutencao.yml up -d  | log debug stop
    fi
    echo "Página de manutenção atualizada." | log debug stop
  fi

  rm $SCRIPTS_PATH/startstop.lock

fi
