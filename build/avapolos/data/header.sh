#!/usr/bin/env bash

run() {
  bash "$1"
  if [[ $? -ne 0 ]]; then
    echo "Ocorreu um erro no script $1!"
    exit 1
  fi
}

generateSecrets() {
cat <<EOL
#Format: SERVICE_USER
export CONTROLE_ADMIN_PASSWORD=Admin@123
export CONTROLE_ADMIN_PASSWORD_HASH=$(echo -n "Admin@123" | md5sum | cut -d ' ' -f 1)
export DB_CONTROLE_POSTGRES_PASSWORD=$(openssl rand -hex 16)
export DB_CONTROLE_AVAPOLOS_PASSWORD=$(openssl rand -hex 16)
export MOODLE_ADMIN_PASSWORD=Admin@123
export DB_MOODLE_POSTGRES_PASSWORD=$(openssl rand -hex 16)
export DB_MOODLE_BDRSYNC_PASSWORD=$(openssl rand -hex 16)
export DB_MOODLE_MOODLE_PASSWORD=$(openssl rand -hex 16)
export PORTAINER_ADMIN_PASSWORD=Admin@123
export WIKI_ADMIN_PASSWORD=Admin@123
export DB_WIKI_POSTGRES_PASSWORD=$(openssl rand -hex 16)
export DB_WIKI_WIKI_PASSWORD=$(openssl rand -hex 16)
EOL
}

setHosts() {
  echo "Redirecionando nomes para a máquina local."
  sudo /bin/sh -c "{
    echo '#--AVAPOLOS BUILD START--'
    echo '127.0.0.1 controle.avapolos'
    echo '127.0.0.1 educapes.avapolos'
    echo '127.0.0.1 portainer.avapolos'
    echo '127.0.0.1 moodle.avapolos'
    echo '127.0.0.1 inicio.avapolos'
    echo '127.0.0.1 traefik.avapolos'
    echo '127.0.0.1 downloads.avapolos'
    echo '127.0.0.1 wiki.avapolos'
    echo '127.0.0.1 naoexisto.avapolos'
    echo '127.0.0.1 manutencao.avapolos'
    echo '#--AVAPOLOS BUILD END--'
  } >> /etc/hosts "
}

unsetHosts() {
  firstLine=$(grep -n "AVAPOLOS BUILD START" /etc/hosts | cut -d: -f1)
  lastLine=$(grep -n "AVAPOLOS BUILD END" /etc/hosts | cut -d: -f1)
  if [[ -z "$firstLine" ]] || [[ -z "$lastLine" ]]; then
    echo "Não foi possível detectar as linhas no unsetHosts!"
    exit 1
  fi
  sudo sed -i "$firstLine","$lastLine"d /etc/hosts
}

export PUID=$(id -u $USER)
export PGID=$(id -g $USER)
export ROOT_DIR=$BUILD_AVAPOLOS_PATH/data
export SERVICES_DIR=$ROOT_DIR/services
export PACK_DIR=$ROOT_DIR/pack

export LOGFILE_PATH=$ROOT_DIR/data_compiler.log
export SECRETS_FILE=$ROOT_DIR/secrets

#Moodle variables.
export MOODLE_DIR=$SERVICES_DIR/moodle
export MOODLE_DATA_DIR=$MOODLE_DIR/data
export MOODLE_RESOURCES_DIR=$MOODLE_DIR/resources

#Wiki variables.
export WIKI_PASSWORD="Admin@123"
export WIKI_DIR=$SERVICES_DIR/wiki
export WIKI_DATA_DIR=$WIKI_DIR/data
export WIKI_RESOURCES_DIR=$WIKI_DIR/resources

#Downloads variables.
export BASIC_DIR=$SERVICES_DIR/basic
export BASIC_DATA_DIR=$BASIC_DIR/data
export BASIC_RESOURCES_DIR=$BASIC_DIR/resources

#Downloads variables.
export TRAEFIK_DIR=$SERVICES_DIR/traefik
export TRAEFIK_DATA_DIR=$TRAEFIK_DIR/data
export TRAEFIK_RESOURCES_DIR=$TRAEFIK_DIR/resources

#Controle variables.
export INICIO_DIR=$SERVICES_DIR/inicio
export INICIO_DATA_DIR=$INICIO_DIR/data
export INICIO_RESOURCES_DIR=$INICIO_DIR/resources

#Manutencao variables.
export MANUTENCAO_DIR=$SERVICES_DIR/manutencao
export MANUTENCAO_DATA_DIR=$MANUTENCAO_DIR/data
export MANUTENCAO_RESOURCES_DIR=$MANUTENCAO_DIR/resources

#Dnsmasq variables.
export DNSMASQ_DIR=$SERVICES_DIR/dnsmasq
export DNSMASQ_DATA_DIR=$DNSMASQ_DIR/data
export DNSMASQ_RESOURCES_DIR=$DNSMASQ_DIR/resources

#DHCPD variables.
export DHCPD_DIR=$SERVICES_DIR/dhcpd
export DHCPD_DATA_DIR=$DHCPD_DIR/data
export DHCPD_RESOURCES_DIR=$DHCPD_DIR/resources

#Export the functions.
export -f run
export -f setHosts
export -f unsetHosts
