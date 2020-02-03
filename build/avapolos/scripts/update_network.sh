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

dhcp="$1"
ip="$2"
interface="$(getInterface)"
gateway="$(echo $ip | awk -F. '{ print $1"."$2"."$3".1" }')"

#Change the address in /etc/interfaces
for line in $(cat /etc/network/interfaces); do
  if [[ $line =~ address ]]; then
    lineNumber=$(cat /etc/network/interfaces | grep -n "$line" | cut -d: -f1)
    newLine='address '$ip
    sed -i "$lineNumber"'s/.*/'"$newLine"'/' /etc/network/interfaces
  fi
done

#Change the gateway in /etc/interfaces
for line in $(cat /etc/network/interfaces); do
  if [[ $line =~ gateway ]]; then
    lineNumber=$(cat /etc/network/interfaces | grep -n "$line" | cut -d: -f1)
    newLine='gateway '$gateway
    sed -i "$lineNumber"'s/.*/'"$newLine"'/' /etc/network/interfaces
  fi
done

ifconfig "$interface" down | log debug installer
ip addr flush dev "$interface" | log debug installer
service networking restart | log debug installer
