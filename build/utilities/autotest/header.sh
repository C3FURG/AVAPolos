#!/usr/bin/env bash

#Default logger variables.
export LOGGER_LVL=${LOGGER_LVL:="debug"}
export LOGFILE_PATH="${LOGFILE_PATH:="autotest.log"}"
export TIMESTAMP_SCHEME=${TIMESTAMP_SCHEME:="%d-%m-%Y %H:%M:%S"}


shutdown_host() { #$1-> IP
  ping -W1 -c1 "$1" > /dev/null
  if [[ $? -eq 0 ]]; then
    ssh "admin@$1" "sudo init 0" > /dev/null
    sleep 5
    if [[ "$2" = "wait" ]]; then
      while : ; do
        ping -W1 -c1 "$1" > /dev/null
        if [[ $? -eq 0 ]]; then
          echo -en "\rWaiting for $1 to shutdown."
          sleep 2
        else
          echo "Host $1 is down."
          break;
        fi
      done
    fi
  else
    echo "Host $1 is already down."
  fi
}

wait_for_host() { #$1-> IP
  ping -W1 -c1 "$1" > /dev/null
  if [[ $? -eq 0 ]]; then
    echo "Host $1 is up."
  else
    while : ; do
      ping -W1 -c1 "$1" > /dev/null
      if [[ $? -eq 0 ]]; then
        echo -en "\rWaiting for $1 to be up."
        sleep 2
      else
        echo "Host $1 is up."
        break;
      fi
    done
  fi
}

wol() { #$1-> MAC
  echo -e $(echo $(printf 'f%.0s' {1..12}; printf "$(echo $1 | sed 's/://g')%.0s" {1..16}) | sed -e 's/../\\x&/g') | nc -w1 -u -b 255.255.255.255 4000
}

start_host() { #$1-> NAME
  echo "Sending WOL packet"
  wol $(python3 fog.py get-mac $1)
}

compile() {
  echo "Compiling installer"
}

greet() {
  echo "AVAPolos - Auto Test"
}

usage() {
  echo "Usage not implemented."
}

#Logger function.
log() { #$1-> mode[debug,info,error,warn] #$2-> source[examples: console,service,cli], reads from STDIN
  if ! [[ -d $LOG_PATH ]]; then
    sudo mkdir -p $LOG_PATH
    sudo chown $USER:$USER -R $LOG_PATH
  fi
  mode="$1"
  source="$2"
  string="$(date "+${TIMESTAMP_SCHEME}")"
  if [[ -z "$source" ]]; then
    string="$string -"
  else
    string="$string - \e[33m$source\e[0m -"
  fi
  shift
  {
    case $mode in
      #                                                                                                BOLD COLOR        RESET
      debug) if [[ $LOGGER_LVL =~ debug ]]; then                 while read data; do if ! [ -z "$data" ]; then echo -e "$string\e[1m\e[37m DEBUG \e[0m- $data"; fi; done; else true; fi; 1>&2 ;;
      info)  if [[ $LOGGER_LVL =~ debug|info ]]; then            while read data; do if ! [ -z "$data" ]; then echo -e "$string\e[1m\e[32m INFO \e[0m- $data";  fi; done; else true; fi; 1>&2 ;;
      warn)  if [[ $LOGGER_LVL =~ debug|info|warn ]]; then       while read data; do if ! [ -z "$data" ]; then echo -e "$string\e[1m\e[93m WARN \e[0m- $data";  fi; done; else true; fi; 1>&2 ;;
      error) if [[ $LOGGER_LVL =~ debug|info|warn|error ]]; then while read data; do if ! [ -z "$data" ]; then echo -e "$string\e[1m\e[91m ERROR \e[0m- $data"; fi; done; else true; fi; 1>&2 ;;
    esac
  } 2>&1 | tee -a $LOGFILE_PATH
}

export -f greet
export -f usage
export -f shutdown_host
export -f wait_for_host
export -f compile
