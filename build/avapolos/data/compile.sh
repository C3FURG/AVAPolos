#!/usr/bin/env bash

dir=$(pwd)
cd ../../preinstall
source header.sh
cd $dir
unset dir
source header.sh

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
		--cleanup)
      for service in $(ls $SERVICES_DIR | grep -v TEMPLATE); do
        cd "$SERVICES_DIR/$service"
        echo "Limpando dados do serviço: $service"
        rm -rf data
      done
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

echo "Assegurando permissões corretas" | log debug data_compiler
sudo chown $USER:$USER -R .

mkdir -p $PACK_DIR/data && rm -rf $PACK_DIR/data/*

echo "Criando rede Docker avapolos_build e proxy" | log debug data_compiler
# add_docker_network avapolos
# add_docker_network proxy
docker network create avapolos || true
docker network create proxy || true

if [[ -z "$(cat /etc/hosts | grep -o 'AVAPOLOS BUILD START')" ]]; then
  setHosts | log debug data_compiler
fi

cd $TRAEFIK_DIR
echo "Compilando traefik" | log info data_compiler
run compile.sh
cp -rf $TRAEFIK_DATA_DIR/* "$PACK_DIR/data/"

cd $INICIO_DIR
echo "Compilando inicio.avapolos" | log info data_compiler
run compile.sh
cp -rf $INICIO_DATA_DIR/* "$PACK_DIR/data/"

cd $MANUTENCAO_DIR
echo "Compilando manutencao" | log info data_compiler
run compile.sh
cp -rf $MANUTENCAO_DATA_DIR/* "$PACK_DIR/data/"

#SERVICES=${SERVICES:-$(ls | grep -v TEMPLATE | grep -v traefik)}
SERVICES=${SERVICES:-$(for svc in $(cat $ROOT_DIR/../services/enabled_services | grep -v educapes); do echo $(echo $svc | cut -d . -f1); done)}
echo "Compilando serviços: $SERVICES" | log info data_compiler
for service in $SERVICES; do
  echo "Compilando serviço $service" | log info data_compiler
  cd "$SERVICES_DIR/$service"
  run compile.sh
  cp -rf $SERVICES_DIR/$service/data/* "$PACK_DIR/data/"
done

if ! [[ "$KEEPALIVE" = "true" ]]; then
  unsetHosts | log debug data_compiler
  cd $TRAEFIK_DIR
  docker-compose down
  for service in $SERVICES; do
    cd "$SERVICES_DIR/$service"
    echo "Parando serviço $service" | log debug data_compiler
    docker-compose down
  done
fi

cd $PACK_DIR
tar --use-compress-program="pigz -9" -cf data.tar.gz data
cp -rf data.tar.gz $ROOT_DIR/../
