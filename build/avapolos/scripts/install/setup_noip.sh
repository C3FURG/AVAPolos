#!/usr/bin/env bash

#Debugging
#set -x

#$1-> Username
#$2-> Password
#$3-> Domain

change_domains() {
  #Change the domain in the traefik.toml
  lineNumber=$(grep -n "domain =" $DATA_PATH/traefik/traefik.toml | cut -d: -f1)
  sed -i "$line"'s/.*/domain\ \=\ '"$DOMAIN"'/' $DATA_PATH/traefik/traefik.toml

  #Change the domain in every service.
  for stack in $(ls $SERVICES_PATH/*.yml); do
      for line in $(cat $stack); do
      if [[ $line =~ frontend.rule=Host: ]]; then
        lineNumber=$(cat $stack | grep -n "$line" | cut -d: -f1)
        svc=$(echo $line | cut -d: -f2 | cut -d. -f1)
        newLine='      - "traefik.frontend.rule=Host:'$svc'.'$DOMAIN'"'
        sed -i "$lineNumber"'s/.*/'"$newLine"'/' $stack
      fi
    done
  done

  #Change the links in the menu
  for line in $(cat $DATA_PATH/inicio/public/index.html); do
    if [[ $line =~ href=\"htt ]]; then
      lineNumber=$(cat $DATA_PATH/inicio/public/index.html | grep -n "$line" | cut -d: -f1)
      str1=$(echo $line | sed -e 's/href\=\"http:\/\///g' | sed -e 's/\"><div><\/div><\/a>//g')
      svc=$(echo $str1 | cut -d. -f1)
      if ! [[ -z $(echo $str1 | grep -o '/') ]]; then
        suffix=$(echo $str1 | cut -d/ -f2 | sed "s/\r//g")
      else
        suffix=""
      fi
      newLine='			<a href=\"http:\/\/'$svc'.'$DOMAIN'\/'$suffix'\"><div><\/div><\/a>'
      sed -i "$lineNumber"'s/.*/'"$newLine"'/' $DATA_PATH/inicio/public/index.html
    fi
  done

  #Change the domains in access_mode.sh
  #FIXME
  services=("MOODLE" "WIKI" "EDUCAPES" "DOWNLOADS")
  for service in ${svcs[@]}; do
    lineNumber=$(cat $SCRIPTS_PATH/access_mode.sh | grep -n "\$$service\_URL=" | cut -d: -f1)
    svc=$(echo $service | tr '[:upper:]' '[:lower:]')
    if ! [[ -z $(echo $str1 | grep -o '/') ]]; then
      suffix=$(echo $str1 | cut -d/ -f2 | sed "s/\r//g")
    else
      suffix=""
    fi
    newLine='$'$service'_URL="'$svc'.'$DOMAIN'"'
    sed -i "$lineNumber"'s/.*/'"$newLine"'/' $SCRIPTS_PATH/access_mode.sh
  done

  #Change the domain in hosts file
  ip=$(bash $INSTALL_SCRIPTS_PATH/get_ip.sh)
  firstLine=$(grep -n "AVAPolos config start" /etc/hosts | cut -d: -f1)
  lastLine=$(grep -n "AVAPolos config end" /etc/hosts | cut -d: -f1)
  sed -i "$firstLine","$lastLine"d /etc/hosts
  {
    echo -e "#AVAPolos config start"
    echo -e "$ip $DOMAIN"
    echo -e "$ip controle.$DOMAIN"
    echo -e "$ip inicio.$DOMAIN"
    echo -e "$ip moodle.$DOMAIN"
    echo -e "$ip wiki.$DOMAIN"
    echo -e "$ip educapes.$DOMAIN"
    echo -e "$ip traefik.$DOMAIN"
    echo -e "$ip menu.$DOMAIN"
    echo -e "$ip downloads.$DOMAIN"
    echo -e "$ip portainer.$DOMAIN"
    echo -e "$ip teste.$DOMAIN"
    echo -e "#AVAPolos config end"
  } >> /etc/hosts

}

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

echo "
USER=\"$1\"
PASS=\"$2\"
DOMAIN=\"$3\"
" > $NOIP_ENV_PATH

source $NOIP_ENV_PATH/noip.env

add_service noip.yml
enable_service noip.yml

stop

change_domains

start
