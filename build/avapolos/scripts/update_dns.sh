#!/usr/bin/env bash

source /etc/avapolos/header.sh
source $SYNC_PATH/variables.sh
source $SYNC_PATH/functions.sh

getInterface() {

  blacklist="lo docker br veth tun"
  priority=("en" "wl")
  for if in $(ifconfig | grep ^[a-zA-Z] | cut -d":" -f1); do
    ifs+=("$if")
  done
  for item in $blacklist; do
    ifs=("${ifs[@]/*$item*}")
  done

  new_ifs=()
  for item in ${ifs[@]}; do
    if ! [ -z "$item" ]; then
      new_ifs+=("$item")
    fi
  done
  ifs=(${new_ifs[@]})
  unset new_ifs

  if [ ${#ifs[@]} -eq 1 ]; then
    interface=${ifs[0]}
  elif [ $INTERACTIVE="false" ]; then
    flag="false"
    while [ "$flag" = "false" ]; do
      for if in $ifs; do
        for counter in $(seq 0 $((${#priority[@]} - 1 ))); do
          if [[ "$if" =~ ${priority[counter]} ]]; then
            interface=$if
            flag="true"
          fi
        done
      done
    done
  fi

  echo $interface
}
updateDNS() {
  #Change the address in Moodle's config.php
  for line in $(cat /etc/network/interfaces); do
    if [[ $line =~ dns-nameservers ]]; then
      lineNumber=$(cat /etc/network/interfaces | grep -n "$line" | cut -d: -f1)
      newLine='dns-nameservers '$1' '$2
      sed -i "$lineNumber"'s/.*/'"$newLine"'/' /etc/network/interfaces
    fi
  done
}

interface=$(getInterface)
dns1="$1"
dns2="$2"

stop

updateDNS "$dns1" "$dns2"

ifconfig "$interface" down | log debug installer
ip addr flush dev "$interface" | log debug installer
service networking restart | log debug installer

start
