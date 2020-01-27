#!/usr/bin/env bash

#Debugging
#set -x

#$1-> Username
#$2-> Password
#$3-> Domain

change_domains() {
  #Change the domain in the traefik.toml
  lineNumber=$(grep -n "domain =" $DATA_PATH/traefik/traefik.toml | cut -d: -f1)
  sed -i "$lineNumber"'s/.*/domain\ \=\ \"'$DOMAIN'\"/' $DATA_PATH/traefik/traefik.toml

  #Change the domain in every service, except the maintenance page.
  for stack in $(ls $SERVICES_PATH/*.yml); do
      for line in $(cat $stack); do
        if [[ $line =~ frontend.rule=Host: ]]; then
          lineNumber=$(cat $stack | grep -n "$line" | cut -d: -f1)
          svc=$(echo $line | cut -d: -f2 | cut -d. -f1)
          if [[ $line =~ \$\{ ]]; then
            break
          fi
          newLine='      - "traefik.frontend.rule=Host:'$svc'.'$DOMAIN'"'
          sed -i "$lineNumber"'s/.*/'"$newLine"'/' $stack
        fi
    done
  done

  #Change the links in the menu
  for line in $(cat $DATA_PATH/inicio/public/index.php); do
    if [[ $line =~ _url=\"http\:\/\/[a-z] ]]; then
      lineNumber=$(cat $DATA_PATH/inicio/public/index.php | grep -n "$line" | cut -d: -f1)
      svc=$(echo $line | cut -d_ -f1 | sed -e 's/\$//g')
      if ! [[ -z $(echo $line | cut -d= -f2 | sed 's/[\";]//g' | sed 's/http:\/\///g' | grep -o /) ]]; then
        suffix=$(echo $line | cut -d= -f2 | sed 's/[\";]//g' | sed 's/http:\/\///g' | cut -d/ -f2)
      else
        unset suffix
      fi
      newLine='		\$'$svc'_url="http:\/\/'$svc'.'$DOMAIN'\/'$suffix'";'
      sed -i "$lineNumber"'s/.*/'"$newLine"'/' $DATA_PATH/inicio/public/index.php
    fi
  done

  #Change the address in Moodle's config.php
  if [[ -f $DATA_PATH/moodle/public/config.php ]]; then
    for line in $(cat $DATA_PATH/moodle/public/config.php); do
      if [[ $line =~ wwwroot ]]; then
        lineNumber=$(cat $DATA_PATH/moodle/public/config.php | grep -n "$line" | cut -d: -f1)
        newLine='$CFG->wwwroot   = "http:\/\/moodle.'$DOMAIN'";'
        sed -i "$lineNumber"'s/.*/'"$newLine"'/' $DATA_PATH/moodle/public/config.php
      fi
    done
  fi

  #Change the address in Wiki's LocalSettings.php
  if [[ -f $DATA_PATH/wiki/public/LocalSettings.php ]]; then
    for line in $(cat $DATA_PATH/wiki/public/LocalSettings.php); do
      if [[ $line =~ wgServer ]] || [[ $line =~ wgScriptPath ]]; then
        lineNumber=$(cat $DATA_PATH/wiki/public/LocalSettings.php | grep -n "$line" | cut -d: -f1)
        newLine='$wgServer = "http:\/\/wiki.'$DOMAIN'";'
        sed -i "$lineNumber"'s/.*/'"$newLine"'/' $DATA_PATH/wiki/public/LocalSettings.php
      fi
    done
  fi

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

source $NOIP_ENV_PATH

stop

if [[ "$1" != "null" ]] && [[ "$2" != "null" ]]; then
  add_service noip.yml
  enable_service noip.yml
fi

change_domains

start
