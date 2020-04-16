#!/usr/bin/env bash

source header.sh
generateSecrets > secrets
chmod 600 secrets
source secrets

while true
do
    case "$1" in
    --help | -h)
			usage
      exit 0
		;;
		--service)
			shift
      SERVICES="$1"
      shift
		;;
		--keep-alive)
			shift
      export KEEPALIVE="true"
		;;
		--ignore-base)
			shift
      export IGNORE_BASE="true"
		;;
		--cleanup)
      for service in $(ls $SERVICES_DIR | grep -v TEMPLATE); do
        cd "$SERVICES_DIR/$service"
        echo "Limpando dados do serviço: $service"
        rm -rf data
        if [[ -f docker-compose.yml ]]; then
          docker-compose down
        fi
      done
      remove_docker_network avapolos
      remove_docker_network proxy
      exit 0
		;;
    -*)
      echo "Opção inválida: $1"
      echo "Utilize o argumento -h para mais informações."
      exit 1
    ;;
		*)
			break
		;;
		esac
done

sudo chown $USER:$USER -R .

mkdir -p $PACK_DIR/data && rm -rf $PACK_DIR/data/*

log debug "Criando rede Docker avapolos e proxy"
add_docker_network avapolos
add_docker_network proxy

if [[ -z "$(cat /etc/hosts | grep -o 'AVAPOLOS BUILD START')" ]]; then
  log debug "Configurando /etc/hosts"
  setHosts
fi

if ! [[ "$IGNORE_BASE" = "true" ]]; then
  export MANUTENCAO=""
  BASE_SERVICES="TRAEFIK INICIO MANUTENCAO DHCPD DNSMASQ"
  log debug "Compilando serviços base: $BASE_SERVICES"
  for service in $BASE_SERVICES; do
    dir=$service"_DIR"
    data_dir=$service"_DATA_DIR"
    cd "${!dir}"
    log info "Compilando $service"
    run compile.sh
    cp -rf "${!data_dir}"/* "$PACK_DIR/data/"
  done
fi

#SERVICES=${SERVICES:-$(ls | grep -v TEMPLATE | grep -v traefik)}
SERVICES=${SERVICES:-$(for svc in $(cat $ROOT_DIR/../services/enabled_services | grep -v educapes); do echo $(echo $svc | cut -d . -f1); done)}
log info "Compilando serviços: $SERVICES"
for service in $SERVICES; do
  log info "Compilando serviço $service" 
  cd "$SERVICES_DIR/$service"
  run compile.sh
  cp -rf $SERVICES_DIR/$service/data/* "$PACK_DIR/data/"
done

if ! [[ "$KEEPALIVE" = "true" ]]; then
  unsetHosts
  cd $TRAEFIK_DIR
  docker-compose down
  cd $INICIO_DIR
  docker-compose down
  cd $MANUTENCAO_DIR
  docker-compose down
  for service in $SERVICES; do
    cd "$SERVICES_DIR/$service"
    log debug "Parando serviço $service" 
    docker-compose down
  done
  remove_docker_network avapolos
  remove_docker_network proxy
fi

cp $ROOT_DIR/secrets $PACK_DIR/data

cd $PACK_DIR
tar --use-compress-program="pigz -9" -cf data.tar.gz data
cp -rf data.tar.gz ../
