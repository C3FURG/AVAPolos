#!/usr/bin/env bash

source header.sh
source .env

# Automatic testing script for AVAPolos solution.

# Ask if the machines need to be imaged.
# If yes, reboot and image them,
# Use FOG API to get MAC Adresses to WOL them back up, use fog api to check for the task status.
# Send installer via scp, and then install it.

# Future versions:
# After installing, add data to moodle and clone it.
# Send to the POLO machine and install it.

# Stellar version:
# Fully automatic testing.


greet

test() {
  #shutdown_host $IP_IES wait
  #shutdown_host $IP_POLO wait
  #python3 fog.py deploy $HOST_IES $HOST_POLO --wait
  wait_for_host $IP_IES
  wait_for_host $IP_POLO
  scp ../../avapolos_beta* admin@$IP_IES:~/
  ssh admin@$IP_IES "sudo ./avapolos_beta* -- -y"
}

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
      log info "alterando nível de log para $1"
      export $LOGGER_LVL="$1"
      echo "$1" > "$ETC_PATH/logger.conf"
      shift
    ;;
    --test)
      echo "Iniciando testes."
      test
      exit 0
    ;;
    *)
      test
      exit 0
    ;;
  esac
done
