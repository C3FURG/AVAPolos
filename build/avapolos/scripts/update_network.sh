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
generateNetworkConfig() { # $1-> interface $2-> ip $3-> netmask $4-> gateway $5-> dns1 $6-> dns2
echo -e "#AVAPolos config start"
echo -e "auto $1"
echo -e "iface $1 inet static"
echo -e "address $2"
echo -e "netmask $3"
echo -e "gateway $4"
echo -e "dns-nameservers $5 $6"
echo -e "#AVAPolos config end"
}
generateHostsConfig() { # $1-> ip(without mask)
if [ -z "$1" ]; then
  log error "Nenhum ip foi passado para o generateHostsConfig" 
  exit 1
fi
echo -e "#AVAPolos config start"
echo -e "$1 avapolos"
echo -e "$1 controle.avapolos"
echo -e "$1 inicio.avapolos"
echo -e "$1 moodle.avapolos"
echo -e "$1 wiki.avapolos"
echo -e "$1 educapes.avapolos"
echo -e "$1 traefik.avapolos"
echo -e "$1 menu.avapolos"
echo -e "$1 downloads.avapolos"
echo -e "$1 portainer.avapolos"
echo -e "$1 teste.avapolos"
echo -e "#AVAPolos config end"
}

interface=$(getInterface)
ip="$1"
gw="$2"
mask="$3"
dns1="$4"
dns2="$5"

stop

# echo "Interface: $(getInterface)"
# echo "IP: $ip"
# echo "Gateway: $gw"
# echo "Netmask: $3"
# echo "DNS 1: $dns1"
# echo "DNS 2: $dns2"

undoConfig /etc/network/interfaces
undoConfig /etc/hosts

generateNetworkConfig "$interface" "$ip" "$mask" "$gw" "$dns1" "$dns2" >> /etc/network/interfaces
generateHostsConfig "$ip" >> /etc/hosts

ifconfig "$interface" down
ip addr flush dev "$interface"
service networking restart

start
