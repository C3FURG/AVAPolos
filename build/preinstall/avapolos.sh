#!/usr/bin/env bash

if [ "$EUID" -ne 0 ]; then
    echo "Este script precisa de permissões elevadas, digite no terminal: sudo avapolos"
    exit
fi

#If the header file is present on the system.
if [ -f "/etc/avapolos/header.sh" ]; then
  #Source it.
  source /etc/avapolos/header.sh
#If it's not present.
else
  #Tell the user and exit with an error code.
  echo "Não foi encontrado o arquivo header.sh" | log error
  exit 1
fi

export LOGFILE_PATH="$LOG_PATH/cli.log"

greet

while true; do
  case "$1" in
    --version | -v)
      #Print version information
      echo "AVAPolos versão: $INSTALLER_VERSION"
	    exit 0
	  ;;
    --help | -h)
      usage
      exit 0
	  ;;
    --loglvl)
      shift
      echo "alterando nível de log para: $1" | log info
      export $LOGGER_LVL="$1"
      echo "$1" > "$ETC_PATH/logger.conf"
      shift
	  ;;
    --start)
      shift
      start $@
      exit 0
	  ;;
    --stop)
      shift
      stop $@
      exit 0
	  ;;
    --restart)
      shift
      echo "Reiniciando avapolos" | log info
      stop $@
      start $@
      exit 0
    ;;
    --install)
      shift
      install $@
      exit 0
    ;;
    --uninstall)
      shift
      uninstall $@
      exit 0
    ;;
    --access)
      shift
      run "$SCRIPTS_PATH/access_mode.sh" $@
      exit 0
    ;;
    --backup | -b)
      shift
      run "$SCRIPTS_PATH/backup.sh" $@
      exit 0
	  ;;
    --restore | -r)
      shift
      run "$SCRIPTS_PATH/restore.sh" $@
      exit 0
    ;;
    --export-all)
      shift
      export-all $@
      exit 0
    ;;
    *)
      usage
      exit 0
    ;;
  esac
done
