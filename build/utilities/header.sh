#!/usr/bin/env bash

installDocker() {
	if ! [[ -f "/etc/init.d/docker" ]]; then
		echo "Instalando docker."
		sudo apt-get install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common
		if [ -z "$(find /etc/apt/ -name *.list | xargs cat | grep '^[[:space:]]*deb' | grep docker)" ]; then
	    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
	    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
	  fi
		sudo apt-get update
		sudo apt-get install -y docker-ce docker-compose
		sudo usermod -aG docker $USER
		clear
		echo "ATENÇÃO: Reinicie o computador para continuar o processo de compilação."
		exit 1
	fi
}

ensureDockerIsActive() {
	if ! [[ $(systemctl is-active docker) = "active" ]]; then
		sudo systemctl start docker.service
	fi
}

installBuildDeps() {
	if ! [ -f .buildDependencies ]; then
		echo "Instalando dependências"
		sudo apt-get install -y --no-install-recommends --no-install-suggests \
		apt-transport-https \
		net-tools \
		ca-certificates \
		curl \
		gnupg-agent \
		software-properties-common \
		apt-rdepends \
		makeself \
		pigz \
		dpkg-dev \
		iputils-ping \
		rsync \
		dpkg-dev \
		makeself \
		&& touch .buildDependencies || exit 1
	fi
}

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

# $1-> Template name
setTemplate() {

  cd $BUILD_DIR_PATH/templates

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
  echo $template > $BUILD_DIR_PATH/active_template

}

checkForActiveTemplate() {
	if [ -f "$BUILD_DIR_PATH/active-template" ]; then
		template=$(cat $BUILD_DIR_PATH/template)
		source $BUILD_DIR_PATH/"$template.sh"
		echo "Utilizando template: $template" | log debug
		echo "Stacks: $stacks" | log debug
		echo "Imagens: $images" | log debug
	else
		setTemplate "completo"
	fi
}

export BUILD_DIR_PATH="$PWD/../"
export BUILD_AVAPOLOS_PATH="$BUILD_DIR_PATH/avapolos"
export BUILD_DATA_PATH="$BUILD_AVAPOLOS_PATH/data"
export INSTALLER_VERSION="beta-0.2-$(date +%d.%m.%y)"


export -f installDocker
export -f ensureDockerIsActive
export -f installBuildDeps
export -f usage
export -f setTemplate
export -f checkForActiveTemplate
