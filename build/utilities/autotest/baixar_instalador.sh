#!/usr/bin/env bash

getInterface() {

  blacklist="lo docker veth tun"
  priority=("br" "en" "wl")
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

getIP() { #$1-> interface
  if ! [ -z "$1" ]; then
    ip=$(ip -o -f inet addr show | grep "$1" | awk '/scope global/ {print $4}')

    if ! [ -z $ip ]; then
      echo $ip
    fi
  fi
}

master=$1

master=${master:="10.230.0.45"}


INTERFACE=$(getInterface)
IP=$(getIP $INTERFACE | cut -d "/" -f1)

echo "My IP is: $IP"
echo "Asking master: $master for installer file."


echo "$IP" | nc $master 4789
