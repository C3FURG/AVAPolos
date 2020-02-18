#!/usr/bin/env bash

#Serviço AVAPolos
#Comandos suportados:
#download_stop $SERVICO -> Para o download de um serviço.
#download_start $SERVICO -> Resume ou força o download de um serviço
#check_services -> Checa os serviços para download.

source /etc/avapolos/header.sh
#source header.sh

PIPE="$SERVICE_PATH/pipe"
#PIPE="pipe"

export LOGGER_LVL="debug"
export LOGFILE_PATH="$LOG_PATH/service.log"

#Para desenvolvimento
#set +e

end() {
  echo "Serviço vai parar.." | log debug
  kill -s SIGTERM $educapes_pid
  rm -f $PIPE
  exit 0
}

update_moodle_hosts() {
  if [[ $(is_enabled moodle.yml) -eq 0 ]]; then
    docker stop moodle > /dev/null
    docker start moodle > /dev/null
    ip=$(bash $INSTALL_SCRIPTS_PATH/get_ip.sh)
    echo "Atualizando hosts do Moodle com o ip: $ip." | log debug service
    docker exec moodle sh -c "echo \"$ip avapolos\" >> /etc/hosts"
  fi
}

trap end EXIT

educapes_download_stop() {
  touch /opt/educapes/no_check
  if [ -z "$educapes_pid" ]; then
    echo "No educapes setup PID specified"
  else
    echo "Enviando SIGTERM para o processo $educapes_pid" | log debug
    kill -s SIGTERM $educapes_pid
  fi
}

educapes_download_start() {
  if [[ -f /opt/educapes/no_check ]]; then
    rm /opt/educapes/no_check
  fi
  echo "Rodando check_educapes" | log debug
  rm -rf "$EDUCAPES_PATH/no_check"
  check_services
}

check_services() {
  cd $SERVICES_PATH
  for service in "$(cat enabled_services) $(cat disabled_services)"; do
    case $service in
      "educapes.yml")
        echo "Checando eduCAPES" | log debug
        run "$INSTALL_SCRIPTS_PATH/setup_educapes.sh" &
        educapes_pid=$!
      ;;
    esac
  done
}

readFromPipe() {
  IFS=' '
  args=()
    if read line <$PIPE; then
      read -a args <<< "$line"
      echo "Argumentos recebidos: ${args[@]:1}"
      case $line in
        check_services )
        check_services
        ;;
        test )
          sleep 5
          touch $SERVICE_PATH/done
        ;;
        export_all )
          export_all
          touch $SERVICE_PATH/done
        ;;
        educapes_download_stop )
          educapes_download_stop
          touch $SERVICE_PATH/done
        ;;
        educapes_download_start )
          educapes_download_start
          touch $SERVICE_PATH/done
        ;;
        restart )
          restart
          touch $SERVICE_PATH/done
        ;;
        stop )
          stop
        ;;
        access_mode* )
          if ! [ -z "${args[@]:1}" ]; then
            run "$SCRIPTS_PATH/access_mode.sh" "${args[@]:1}"
            touch $SERVICE_PATH/done
          else
            echo "Comando inválido, argumentos insuficientes." | log error
          fi
        ;;
        update_network* )
          if ! [ -z "${args[@]:1}" ]; then
            run "$SCRIPTS_PATH/update_network.sh" "${args[@]:1}"
            touch $SERVICE_PATH/done
          else
            echo "Comando inválido, argumentos insuficientes." | log error
          fi
        ;;
        update_sync_remote_ip* )
          if ! [ -z "${args[@]:1}" ]; then
            run "$SYNC_PATH/setRemoteAddr.sh" "${args[@]:1}"
            touch $SERVICE_PATH/done
          else
            echo "Comando inválido, argumentos insuficientes." | log error
          fi
        ;;
        backup* )
          run "$SCRIPTS_PATH/backup.sh" "${args[@]:1}"
          touch $SERVICE_PATH/done
        ;;
        restore* )
          if ! [ -z "${args[@]:1}" ]; then
            run "$SCRIPTS_PATH/restore.sh" "${args[@]:1}"
            touch $SERVICE_PATH/done
          else
            echo "Comando inválido, argumentos insuficientes." | log error
          fi
        ;;
        setup_dns* )
          if ! [ -z "${args[@]:1}" ]; then
            run "$INSTALL_SCRIPTS_PATH/setup_dns.sh" "${args[@]:1}"
            touch $SERVICE_PATH/done
          else
            echo "Comando inválido, argumentos insuficientes." | log error
          fi
        ;;
        *)
          echo "O serviço recebeu um comando não suportado: $line" | log error
        ;;
      esac
  fi
}

main() {
  readFromPipe
  sleep 1
}

if [[ ! -p $PIPE ]]; then
    mkfifo $PIPE
    chown avapolos:avapolos $PIPE
fi

echo "Daemon AVAPolos iniciado." | log info
echo "Rodando check incial automático." | log debug

check_services &
update_moodle_hosts &

while true; do
  main
done
