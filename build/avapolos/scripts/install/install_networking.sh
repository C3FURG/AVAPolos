#!/usr/bin/env bash

#-------------------------------------------#
# AVAPolos - Script de configuração de rede #
#-------------------------------------------#

#This script needs to run as root.
if [ "$EUID" -ne 0 ]; then
  echo "Este script precisa ser rodado como root"
  exit
fi

#If the header file is present on the system.
if [ -f "/etc/avapolos/header.sh" ]; then
  #Source it.
  source /etc/avapolos/header.sh
#If it's not present.
else
  #Tell the user and exit with an error code.
  echo "Não foi encontrado o arquivo header.sh"
  exit 1
fi

#----------------------------------------------------------

enableDnsmasq="false"
log debug  "install_networking.sh" 
log info  "Configurando rede." 

#----------------------------------------------------------

rm -rf $NETWORKING_PATH/enable

#Functions used to get the default network configuration.
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
  # else
  #   log warn "A interface principal não foi detectada automaticamente"
  #   option=$(input "Deseja selecionar uma manualmente?" "sim" "nao" 1 "Selecione uma opção.")
  #   if [ "$option" = "nao" ]; then
  #     log error "Cancelando instalação."
  #     exit 1
  #   fi
  #
  #   log debug "Interfaces detectadas:"
  #   for counter in ${!ifs[@]}; do
  #     log debug "$counter. ${ifs[counter]}"
  #   done
  #   flag=false
  #   while [ "$flag" = "false" ]; do
  #     echo "Selecione uma interface: (0-$c)"
  #     read option
  #     for counter in ${!ifs[@]}; do
  #       if [ "$option" = "$counter" ]; then
  #         flag="true"
  #       fi
  #     done
  #   done
  #   interface=${ifs[option]}
  fi

  echo $interface > $INSTALL_SCRIPTS_PATH/interface
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
getGateway() { #$1-> interface
  if ! [ -z "$1" ]; then
    gw=$(ip route | grep "default" | grep "$1" | awk '{print $3}')
    echo $gw
  fi
}
getNameservers(){ #$1-> interface

  cmdRet=$(systemd-resolve --status)
  hasDns=$(echo $cmdRet | grep -o "DNS Servers: ")

  if ! [ -z "$hasDns" ]; then
    ifstart=$(echo "$cmdRet" | grep "(""$1"")" -m 1 -n | cut -d":" -f1)
    lineEnd=$(echo "$cmdRet" | wc -l)
    ifFromEnd=$(( $lineEnd - $ifstart ))
    #try to find DNS Domain
    endLink=$(echo "$cmdRet" | tail -n $ifFromEnd | grep 'Link' -m 1 -n | cut -d":" -f1)
    if [ -z "$endLink" ]; then
       #try to find next link
       endLink=$(echo "$cmdRet" | tail -n $ifFromEnd | grep 'DNS Domain' -m 1 -n | cut -d":" -f1)
       if [ -z "$endLink" ]; then
          endLink=$lineEnd
       fi
    fi
    if [ ! $endLink -eq $lineEnd ]; then
       endLink=$(( $endLink - 1))
    fi

    cmdFromIf=$(echo "$cmdRet" | tail -n $ifFromEnd | head -n $endLink)
    dnsArr=$(echo "$cmdFromIf" | rev | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}\ ' | rev)
    newDnsArr=()
    for dns in $dnsArr; do
      newDnsArr+=("$dns")
    done
    dnsArr=(${newDnsArr[@]})
    unset newDnsArr

    echo ${dnsArr[@]}
  else
    echo ""
  fi

}
getNetmask() { #$1-> interface
  if ! [ -z "$1" ]; then
    netmask=$(ifconfig $1 | grep netmask | awk '{print $4}')
    echo $netmask
  fi
}

#This function disables Network-Manager, Netplan and systemd-resolved.
disableDefaultNetworkServices() {
  if [ -f "/etc/init.d/network-manager" ]; then
    log debug  "Desabilitando serviço padrão de gerenciamento de redes." 
    sudo systemctl disable NetworkManager 
    sudo systemctl stop NetworkManager 
    sudo systemctl mask NetworkManager
  fi
  if ! [ -z "$(command -v netplan)" ]; then
    log debug  "Desinstalando netplan" 
    sudo apt-get remove netplan.io -y 
  fi
  log debug  "Parando serviço padrão de nomes" 
  sudo systemctl stop systemd-resolved 
  sudo systemctl disable systemd-resolved 
  sudo systemctl mask systemd-resolved 
}

#These functions generate the required configurations.
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
generateResolvConfig() { #$1 DNS1 $2 DNS2
  for arg in $@; do
    echo -e "nameserver $arg"
  done
}

#Main function
main() {

  log debug "getInterface" 
  INTERFACE=$(getInterface)
  log debug "interface selecionada: $INTERFACE" 

  log debug "getIP" 
  IP=$(getIP $INTERFACE)
  log info "IP detectado: $IP" 

  if [ -z "$IP" ]; then

    enableDHCP="true"
    IP="10.254.0.1/16"
    NS1="10.254.0.1"
    NS2=""
    GATEWAY="10.254.0.1"
    NETWORK="10.254.0.0"
    NETMASK="255.255.0.0"

    log info "+-----------------------------------------------------" 
    log info "|Nenhum ip detectado, utilizando configurações padrão." 
    log info "|Os seguintes parâmetros serão configurados:" 
    log info "|Interface:$interface" 
    log info "|IP do Host: 10.254.0.1/16" 
    log info "|Servidor DNS: 10.254.0.1" 
    log info "|Gateway da rede: 10.254.0.1" 
    log info "+-----------------------------------------------------" 
    log info "|Subrede estática: 10.254.0.0" 
    log info "|Subrede DHCP: 10.254.1.0" 
    log info "+-----------------------------------------------------" 

  else

    log debug "getGateway" 
    GATEWAY=$(getGateway $INTERFACE)
    log debug "Gateway detectado: $GATEWAY" 

    log debug "getNameservers" 
    DNS=($(getNameservers $INTERFACE))
    log debug "Servidores DNS detectados: "${DNS[@]} 

    log debug "getNetwork" 
    NETWORK=$(getNetwork $IP)
    log debug "Rede detectada: $NETWORK" 

    log debug "getNetmask" 
    NETMASK=$(getNetmask $INTERFACE)
    log debug "Máscara de rede detectada: $NETMASK" 

    if [ -z "$DNS" ]; then
      NS1="1.1.1.1"
      NS2="8.8.8.8"
    log warn "Nenhum servidor DNS detectado, configurando automaticamente." 
    else
      counter=0
      for ns in ${DNS[@]}; do
        counter=$(($counter + 1))
        eval "NS$counter=$ns";
      done
    fi
  fi

  if [ "$enableDHCP" = "true" ]; then
    log debug "dhcpd e dnsmasq será iniciado." 
    enable_service dhcpd.yml
    enable_service dnsmasq.yml
  else
    log info "+-------------------------------------------" 
    log info "|Os seguintes parâmetros serão configurados:" 
    log info "|Interface:$INTERFACE" 
    log info "|IP do Host: $IP" 
    log info "|Gateway da rede: $GATEWAY" 
    log info "|DNS1: $NS1" 
    log info "|DNS2: $NS2" 
    log info "+--------------------------------------------" 
  fi

  disableDefaultNetworkServices

  log debug "Configurando arquivo /etc/network/interfaces" 
  # $1-> interface $2-> ip $3-> netmask $4-> gateway $5-> dns1 $6-> dns2
  generateNetworkConfig "$INTERFACE" "$IP" "$NETMASK" "$GATEWAY" "$NS1" "$NS2" >> /etc/network/interfaces
  ifconfig "$INTERFACE" down 
  ip addr flush dev "$INTERFACE" 
  service networking restart 

  log debug "Aplicando configurações no arquivo /etc/hosts" 
  generateHostsConfig $(echo "$IP" | cut -d "/" -f1) >> /etc/hosts

  log debug "Aplicando configurações no resolv.conf"
  rm -rf /etc/resolv.conf
  generateResolvConfig "$NS1" "$NS2" > /etc/resolv.conf
  chmod 777 /etc/resolv.conf

  cd $ROOT_PATH
  echo "router.yml" >> $SERVICES_PATH/enabled_services
  echo "hub_name.yml" >> $SERVICES_PATH/enabled_services

}

#----------------------------------------------------------

main
