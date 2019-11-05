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
#export LOGFILE_PATH="service.log"

#Para desenvolvimento
#set +e

end() {
  echo "Serviço vai parar.." | log debug
  download_stop educapes
  rm -f $PIPE
  exit 0
}

trap end EXIT

download_stop() {
  if [ -z "$1" ]; then
    echo "Nenhum serviço foi passado para o download_stop." | log error
  else
    arg=$(sanitize $1)
    pid=$(pgrep -f setup_"$arg".sh)
    touch /opt/$arg/no_check
    if [ -z "$pid" ]; then
      echo "PID do processo de setup do serviço $arg não foi encontrado!" | log error
    else
      echo "Enviando SIGTERM para o processo $pid" | log debug
      kill -s SIGTERM $pid
    fi
  fi
}

download_start() {
  if [ -z "$1" ]; then
    echo "Nenhum serviço foi passado para o download_start." | log error
  else
    arg=$(sanitize $1)
    rm -f /opt/$arg/no_check
    case $arg in
      educapes)
        echo "Rodando check_educapes" | log debug
        check_educapes
      ;;
    esac
  fi
}

check_servicePacks() {
  if [ ! -d "$SERVICES_PATH" ]; then
    echo "Diretório dos serviços AVAPolos não foi encontrado!" | log error
  else
    cd $SERVICES_PATH
    enabled_services=$(cat enabled_services)
    disabled_services=$(cat disabled_services)
    services="$enabled_services $disabled_services"
    echo "Serviços lidos: $services" | log debug
    for service in $services; do
      case $service in
        "educapes.yml")
          echo "Rodando função: check_educapes" | log debug
          check_educapes
        ;;
      esac
    done
  fi
}

check_educapes() {
  mkdir -p $EDUCAPES_PATH
  cd $EDUCAPES_PATH
  if [ -f "no_check" ]; then
    echo "O serviço está configurado para não executar o download automaticamente!" | log debug
    exit
  fi
  if ! [ -f "setup_done" ]; then
    cd $INSTALL_SCRIPTS_PATH
    echo "Rodando script: setup_educapes.sh" | log debug
    bash setup_educapes.sh &
    #echo "Rodando disown" | log debug
    #disown -h -ar $!
  else
    echo "eduCAPES service is already set up." | log info
  fi
}

readFromPipe() {
  IFS=' '
  args=()
    if read line <$PIPE; then
      read -a args <<< "$line"
      case $line in
        download_stop* )
          if ! [ -z "${args[1]}" ]; then
            download_stop "${args[1]}"
            touch $SERVICE_PATH/done
          else
            echo "Comando inválido, argumentos insuficientes." | log error
          fi
        ;;
        download_start* )
          if ! [ -z "${args[1]}" ]; then
            download_start "${args[1]}"
            touch $SERVICE_PATH/done
          else
            echo "Comando inválido, argumentos insuficientes." | log error
          fi
        ;;
        check_services )
          check_servicePacks
        ;;
        start )
          start
          touch $SERVICE_PATH/done
        ;;
        stop )
          stop
          touch $SERVICE_PATH/done
        ;;
        access_mode* )
          if ! [ -z "${args[1]}" ]; then
            run "$SCRIPTS_PATH/access_mode.sh" "${args[1]}"
            touch $SERVICE_PATH/done
          else
            echo "Comando inválido, argumentos insuficientes." | log error
          fi
        ;;
        backup* )
          run "$SCRIPTS_PATH/backup.sh" "${args[@]}"
          touch $SERVICE_PATH/done
        ;;
        restore* )
          if ! [ -z "${args[1]}" ]; then
            run "$SCRIPTS_PATH/restore.sh" "${args[1]}"
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
}

if [[ ! -p $PIPE ]]; then
    mkfifo $PIPE
fi

echo "Daemon AVAPolos iniciado." | log info
echo "Rodando check incial automático." | log debug
check_servicePacks

while true; do
  main
done
