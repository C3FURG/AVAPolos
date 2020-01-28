#!/usr/bin/env bash

source /etc/avapolos/header.sh
source $SYNC_PATH/variables.sh
source $SYNC_PATH/functions.sh

update_manutencao() {
  echo "Atualizando a página de manutenção" | log debug start
  unset MANUTENCAO
  for service in $(cat stopped_services); do
    rule="$(cat $service | grep traefik.frontend.rule=Host: | cut -d: -f2 | cut -d\" -f1)"
    MANUTENCAO+=" $rule"
  done
  MANUTENCAO=$(echo $MANUTENCAO | sed 's/\ /\,/g')
  export MANUTENCAO
  docker-compose -p avapolos -f manutencao.yml down | log debug start
  docker-compose -p avapolos -f manutencao.yml up -d | log debug start
  echo "Página de manutenção atualizada." | log debug start
}

apply_fixes() {
  echo "Aplicando correções para bugs do Docker" | log debug start

  #We have to start all, and apply workarounds.
  # service docker stop
  # sudo rm -r /var/lib/docker/network/files/
  # service docker start

  # for iface in $(ip -o -4 addr show | grep 172.12 | awk '{print $2}'); do
    #   sudo ip link delete $iface
    # done


}

if [ -f $SCRIPTS_PATH/startstop.lock ]; then
  echo "Já existe um processo utilizando esse script!" | log error start
else
  touch $SCRIPTS_PATH/startstop.lock

  #Create the necessary files if they weren't created.
  touch $SERVICES_PATH/stopped_services
  touch $SERVICES_PATH/started_services

  services=""
  export PUID=$(id -u avapolos)
  export PGID=$(id -g avapolos)
  export COMPOSE_IGNORE_ORPHANS=1
  export EDUCAPES_PATH
  export SERVICE_PATH
  export LOG_PATH
  export MANUTENCAO=""
  export BACKUPS_PATH

  case $1 in
    --silent | -s)
      silent="y"
      shift
    ;;
    *)
      #arg=$(sanitize $1)
      arg=$1
      services="$arg"
    ;;
  esac

  cd $SCRIPTS_PATH

  if ! ps ax | grep -v grep | grep docker > /dev/null
  then
      echo "Docker não está rodando, inicializando.."
      sudo systemctl start docker | log debug start
  fi

  if [ -z "$(cat $SERVICES_PATH/stopped_services)" ]; then
    echo "Todos os serviços já foram iniciados." | log error start
    echo "Caso algum serviço apresente erros, utilize o comando --restart para reiniciar a solução." | log error start
  else

    cd $SERVICES_PATH

    if [ -z "$services" ]; then
      services=$(cat $SERVICES_PATH/enabled_services)
    fi

    for service in $services; do
        if [ -z "$(cat started_services | grep -o $service)" ]; then
          if [ "$service" = "moodle.yml" ]; then
            echo "Iniciando Moodle." | log debug start
            docker-compose -p avapolos -f $service up --no-start | log debug start
            startDBMaster
            stopDBSync
            startMoodle
          else
            echo "Iniciando serviço $service" | log debug start
            docker-compose -p avapolos -f $service up -d | log debug start
          fi
          echo $service >> $SERVICES_PATH/started_services
          sed -i '/'"$(sanitize $service)"'/d' stopped_services
        else
          echo "O serviço $service já está iniciado, ignorando..." | log info start
        fi
    done

    update_manutencao

  fi

  rm $SCRIPTS_PATH/startstop.lock
  source $NOIP_ENV_PATH
  echo "Acesse o portal da solução no seguinte link: http://inicio.$DOMAIN"

fi
