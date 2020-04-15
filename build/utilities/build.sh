#!/usr/bin/env bash

source header.sh

installDocker
ensureDockerIsActive
installBuildDeps

echo $INSTALLER_VERSION > $BUILD_DIR_PATH/version
sudo chown $USER:$USER -R $BUILD_DIR_PATH
cd $BUILD_AVAPOLOS_PATH

source header.sh

export LOGFILE_PATH="$BUILD_DIR_PATH/build.log"
export LOGGER_LVL="info"

checkForActiveTemplate

pull="n"
export update="y"
export update_data="y"
export build_data="y"
export update_deps="y"
export update_images="y"

echo "-----------------" | log info
echo "Iniciando script." | log info
echo "-----------------" | log info

while true
do
    case "$1" in
    --version | -v)
      #Print version information
      echo "AVAPolos versão: $INSTALLER_VERSION"
	    exit 0
	  ;;
    --template)
      shift
      setTemplate $1
      continue
      shift
	  ;;
		--pull-data)
			pull="y"
			shift
		;;
		--no-update)
      export update="n"
      export update_data="n"
      export update_deps="n"
      export update_images="n"
      echo "Nada será atualizado." | log info
			shift
		;;
		--no-update-deps)
			export update_deps="n"
      echo "As dependências não serão atualizadas." | log info
			shift
		;;
		--no-update-images)
			export update_images="n"
      echo "As imagens não serão atualizadas." | log info
			shift
		;;
		--no-update-data)
			export update_data="n"
      echo "A pasta data não será atualizada." | log info
			shift
		;;
		--no-build-data)
			export build_data="n"
      echo "A pasta data não será compilada." | log info
			shift
		;;
		--help | -h)
			usage
      exit 0
		;;
		--loglvl)
			shift
      export LOGGER_LVL="$1"
      echo "Mudando nível de log para: $1" | log info
      shift
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

if [ $update_deps = "n" ] && [ $update_images = "n" ]; then
	export update="n"
fi

start=$(date +%s)

cd $BUILD_DIR_PATH/avapolos/services
echo "" > enabled_services
for stack in $stacks; do
  echo "$stack" >> enabled_services
done

cd $BUILD_DIR_PATH/avapolos/resources/docker_images
echo "" > images
for image in $images; do
  echo "$image" >> images
done

if [ "$update" = "y" ]; then
  cd $BUILD_DIR_PATH/avapolos/resources
  bash update_resources.sh
  	if [ "$?" -ne 0 ]; then
	echo "Erro na atualização dos recursos."
	exit 1
	fi
fi

log info "Gerando instalador com a versão: $INSTALLER_VERSION"

#FIXME
if [ "$pull" = "y" ]; then
	echo "Buscando serviços da instalação atual." | log debug
  sudo avapolos --stop
	echo "Compactando pacote de servicos." | log debug
  tar --use-compress-program="pigz -9" -cf $BUILD_DIR_PATH/avapolos/data.tar.gz $ROOT_PATH/data
  cd $installRoot
  sudo chown $USER:$USER -R "$installRoot"
	sudo avapolos --start
elif [ "$build_data" = "y" ]; then
	echo "Compilando os dados dos serviços" | log info
	cd $BUILD_DATA_PATH
	bash compile.sh
fi

mkdir -p ../packing
mkdir -p ../installer-packing

sudo chown $USER:$USER -R $BUILD_DIR_PATH

echo "Executando rsync." | log debug
rsync -avmq --progress $BUILD_DIR_PATH $BUILD_DIR_PATH/packing --exclude data --delete

echo "Empacotando solução." | log info
cd $BUILD_DIR_PATH/packing && tar --use-compress-program='pigz -9' -cf AVAPolos.tar.gz *

mv AVAPolos.tar.gz $BUILD_DIR_PATH/installer-packing
cp $BUILD_DIR_PATH/avapolos/startup.sh $BUILD_DIR_PATH/installer-packing
makeself -q --pigz --target $INSTALLER_DIR_PATH --needroot . $INSTALLER_FILENAME 'Instalador da solução AVAPolos' './startup.sh'

rm -rf AVAPolos.tar.gz

mv -f $INSTALLER_FILENAME ..
cd ..

end=$(date +%s)

runtime=$((end-start))

echo "---- Compilação Concluída ----" | log info
echo "Instalador disponível: $INSTALLER_FILENAME" | log info
echo "Tamanho: $(du -h $INSTALLER_FILENAME | awk {'print $1'})" | log info
echo "Em "$runtime"s." | log info

# sudo docker run -it \
#   -e PUID=$(id -u $USER) \
#   -e PGID=$(id -g $USER) \
#   -v /var/run/docker.sock:/run/docker.sock \
#   -v $(which docker):/bin/docker \
#   -v $dir:/home/avapolos/avapolos-infra \
#   -v /usr/local/bin/avapolos:/usr/local/bin/avapolos \
#   avapolos/build:v0 \
#   "/compilar.sh $@"
