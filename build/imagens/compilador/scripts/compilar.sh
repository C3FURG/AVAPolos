#!/usr/bin/env bash

cd /home/avapolos/avapolos-infra/build

cd preinstall
source header.sh
cd ../utilities
export compilerRoot=$PWD
cd ../avapolos
export installRoot=$PWD

usage() {
  echo "AVAPolos [Build] - Levando a educação a distância aonde a Internet não alcança"
  echo "Uso: build.sh [OPÇÃO]"
  echo ""
  echo "Comandos básicos:"
  echo -e "  -h,  --help                Mostra este texto de ajuda."
  echo -e "  -v,  --version             Mostra a versão da solução."
  echo ""
  echo "Opcionais:"
  echo -e "       --pull-data           Captura os dados dos serviços da instalação atual"
  echo -e "                             e os utiliza nesta compilação."
  echo -e "       --no-update           Não atualiza."
  echo -e "       --no-update-data      Não atualiza o arquivo compactado da pasta data."
  echo -e "       --no-update-deps      Não atualiza as dependências."
  echo -e "       --no-update-images    Não atualiza as imagens Docker."
  echo -e "       --template [NOME]     Seleciona um template de serviços ou mostra os templates"
  echo -e "                             disponíveis."
}

setTemplate() { #$1 -> Template name
  cd $compilerRoot/../templates
  if [ -z "$1" ]; then
    templates=($(ls | cut -d "." -f1))
    echo "Aqui está uma lista de templates:"
    PS3="Selecione uma opção para ler sua descrição: "
    select opt in "${templates[@]}" ; do
        source "$opt".sh
        echo ""
        echo "$description"
        echo ""
        input "Deseja utilizar este template?" "sim" "nao" 0 "Selecione uma opção!"
        if [ "$option" = "sim" ]; then
          template=$opt
          break
        fi
    done
  else
    if [ -f "$1.sh" ]; then
      source "$1".sh
      template="$1"
    else
      echo "O Template especificado não existe." | log error
      exit 1
    fi
  fi
  echo "Template $template selecionado" | log debug
  echo "Stacks: $stacks" | log debug
  echo "Imagens: $images" | log debug
  echo $template > $compilerRoot/template
}

export LOGFILE_PATH="$compilerRoot/build.log"
#export LOGGER_LVL="debug"


sudo chown $USER:$USER -R $installRoot
echo "chown no installRoot" | log debug

cd $compilerRoot

if [ -f "template" ]; then
  template=$(cat template)
  cd ../templates
  source $template.sh
  echo "Utilizando template: $template" | log debug
  echo "Stacks: $stacks" | log debug
  echo "Imagens: $images" | log debug
else
  setTemplate "completo"
fi

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
			export update_data="n"
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

start=$(date +%s)

cd $installRoot

cd services
echo "" > enabled_services
for stack in $stacks; do
  echo "$stack" >> enabled_services
done

cd ../resources/docker_images
echo "" > images
for image in $images; do
  echo "$image" >> images
done

if [ "$update" = "y" ]; then
  cd $installRoot/resources
  bash update_resources.sh
  if [ "$?" -ne 0 ]; then
		log error "Erro no script na atualização das dependências"
		exit
	fi
fi

cd $installRoot

if [ $build_data = "y" ]; then
  cd data
  bash compile.sh
  cd ../
fi

echo "Gerando instalador com a versão: $INSTALLER_VERSION" | log info

# if [ ! -d "data" ]; then
#   echo "tar xfzv data.tar.gz" | log debug
# 	tar xfz data.tar.gz
# fi

if [ "$pull" = "y" ]; then
	echo "Buscando serviços da instalação atual." | log debug
  sudo avapolos --stop
	echo "Compactando pacote de servicos." | log debug
  tar --use-compress-program="pigz -9" -cf $installRoot/data.tar.gz $ROOT_PATH/data
  cd $installRoot
  sudo chown $USER:$USER -R "$installRoot"
	sudo avapolos --start
elif [ "$update_data" = "y" ]; then
	echo "Usando dados da pasta build." | log debug
	echo "$ATENCAO Compactando pacote de servicos." | log debug
  tar --use-compress-program="pigz -9" -cf data.tar.gz data
fi

mkdir -p ../pack

sudo chown $USER:$USER $compilerRoot/../ -R

echo "Executando rsync." | log debug
if ! [[ $LOGGER_LVL =~ debug ]]; then
  command="rsync -avmq --progress . ../pack --exclude data --delete  2>&1 | log error"
else
  command="rsync -avm --progress . ../pack --exclude data --delete  2>&1 | log debug"
fi
eval $command
unset command

cd ../pack


#tar cf - . -P | pv -s $(du -sb . | awk '{print $1}') | gzip > AVAPolos.tar.gz
#tar cf  AVAPolos.tar * | pigz > AVAPolos.tar.gz
echo "Empacotando solução." | log info
if ! [[ $LOGGER_LVL =~ debug ]]; then
  command="tar --use-compress-program='pigz -9' -cf AVAPolos.tar.gz *  2>&1 | log error"
else
  command="tar --use-compress-program='pigz -9' -cf AVAPolos.tar.gz *  2>&1 | log debug"
fi
eval $command
unset command


mv AVAPolos.tar.gz ../preinstall

cd ../preinstall

echo "Executando makeself." | log debug
if ! [[ $LOGGER_LVL =~ debug ]]; then
  command="makeself -q --pigz --target $INSTALLER_DIR_PATH --needroot . $INSTALLER_FILENAME 'Instalador da solução AVAPolos' './startup.sh' 2>&1 | log error"
else
  command="makeself --pigz --target $INSTALLER_DIR_PATH --needroot . $INSTALLER_FILENAME 'Instalador da solução AVAPolos' './startup.sh' 2>&1 | log debug"
fi
eval $command
unset command

rm -rf AVAPolos.tar.gz

mv -f $INSTALLER_FILENAME ..
cd ..

end=$(date +%s)

runtime=$((end-start))

echo "---- Compilação Concluída ----" | log info
echo "Instalador disponível: $INSTALLER_FILENAME" | log info
echo "Tamanho: $(du -h $INSTALLER_FILENAME | awk {'print $1'})" | log info
echo "Em "$runtime"s." | log info
