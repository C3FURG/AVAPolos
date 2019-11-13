#!/usr/bin/env bash

set -e

#Paths
export ROOT_PATH="/opt/avapolos"
export DATA_PATH="$ROOT_PATH/data"
export NETWORKING_PATH="$ROOT_PATH/networking"
export SCRIPTS_PATH="$ROOT_PATH/scripts"
export INSTALL_SCRIPTS_PATH="$SCRIPTS_PATH/install"
export RESOURCES_PATH="$ROOT_PATH/resources"
export IMAGES_PATH="$RESOURCES_PATH/docker_images"
export DEPENDENCIES_PATH="$RESOURCES_PATH/dependencies"
export SYNC_PATH="$SCRIPTS_PATH/sync"
export ETC_PATH="/etc/avapolos"
export LOG_PATH="/var/log/avapolos"
export INSTALLER_DIR_PATH="/opt/avapolos_installer"
export TMP_PATH="/tmp/avapolos"
export EDUCAPES_PATH="/opt/educapes"
export SERVICES_PATH="$ROOT_PATH/services"
export SERVICE_PATH="$ETC_PATH/service"
export BACKUPS_PATH="$ROOT_PATH/backups"

#User Variables
export AVAPOLOS_USER="avapolos"
export AVAPOLOS_GROUP="avapolos"
export HOME_PATH="/home/$AVAPOLOS_USER"
export SSH_PATH="$HOME_PATH/.ssh"

#Default logger variables.
export LOGGER_LVL=${LOGGER_LVL:="debug"}
export LOGFILE_PATH="${LOGFILE_PATH:="$LOG_PATH/avapolos.log"}"
export TIMESTAMP_SCHEME=${TIMESTAMP_SCHEME:="%d-%m-%Y %H:%M:%S"}

#Version file retrieval.
if [ -f $ETC_PATH/version ]; then
  export INSTALLER_VERSION="$(cat /etc/avapolos/version)"
elif [ -f version ]; then
  export INSTALLER_VERSION="$(cat version)"
else
  echo "O arquivo version não foi encontrado."
  exit 1
fi

export INSTALLER_FILENAME="avapolos_$INSTALLER_VERSION"

#Logger function.
log() { #$1-> mode[debug,info,error,warn] #$2-> source[examples: console,service,cli], reads from STDIN
  if ! [[ -d $LOG_PATH ]]; then
    sudo mkdir -p $LOG_PATH
    sudo chown $USER:$USER -R $LOG_PATH
  fi
  mode="$1"
  source="$2"
  string="$(date "+${TIMESTAMP_SCHEME}")"
  if [[ -z "$source" ]]; then
    string="$string -"
  else
    string="$string - \e[33m$source\e[0m -"
  fi
  shift
  {
    case $mode in
      #                                                                                                BOLD COLOR        RESET
      debug) if [[ $LOGGER_LVL =~ debug ]]; then                 while read data; do if ! [ -z "$data" ]; then echo -e "$string\e[1m\e[37m DEBUG \e[0m- $data"; fi; done; else true; fi; 1>&2 ;;
      info)  if [[ $LOGGER_LVL =~ debug|info ]]; then            while read data; do if ! [ -z "$data" ]; then echo -e "$string\e[1m\e[32m INFO \e[0m- $data";  fi; done; else true; fi; 1>&2 ;;
      warn)  if [[ $LOGGER_LVL =~ debug|info|warn ]]; then       while read data; do if ! [ -z "$data" ]; then echo -e "$string\e[1m\e[93m WARN \e[0m- $data";  fi; done; else true; fi; 1>&2 ;;
      error) if [[ $LOGGER_LVL =~ debug|info|warn|error ]]; then while read data; do if ! [ -z "$data" ]; then echo -e "$string\e[1m\e[91m ERROR \e[0m- $data"; fi; done; else true; fi; 1>&2 ;;
    esac
  } 2>&1 | tee -a $LOGFILE_PATH
}

#Greeting function.
greet() {
  echo ""
  echo "+--------+"
  echo "|AVAPolos|"
  echo "+--------+"
  echo ""
  echo "Universidade Federal do Rio Grande - FURG"
  echo "Centro de Ciências Computacionais - C3"
  echo "Coordenação de Aperfeiçoamento de Pessoal de Nível Superior - CAPES"
  echo "BUILD EXPERIMENTAL INFRA."
  echo ""
}

#Sanitize user input.
sanitize() {
  escaped=$1
  escaped="${escaped//\\/\\\\}"
  escaped="${escaped//\//\\/}"
  escaped="${escaped//\*/\\*}"
  escaped="${escaped//./\\.}"
  escaped="${escaped//\[/\\[}"
  escaped="${escaped//\[/\\]}"
  escaped="${escaped//^/\\^}"
  escaped="${escaped//\$/\\\$}"
  escaped="${escaped//[$'\n']/}"
  echo $escaped
}

#Input function.
input(){ # $1 = message $2 = option 1 (default) $3 = option 2 $4 = useDefault (0 or 1) $5 = errorMessage
   option1=$(tr '[:upper:]' '[:lower:]' <<< "$2" )
   option2=$(tr '[:upper:]' '[:lower:]' <<< "$3" )
   if [ -z $4 ]; then
      useDefault="1";
   else
      useDefault=$4;
   fi
   if [ "$useDefault" = "1" ]; then
      labelDefault=$(tr '[:lower:]' '[:upper:]' <<< "$2" )
   else
      labelDefault=$(tr '[:upper:]' '[:lower:]' <<< "$2" )
   fi
   option="§"
   while ! [[ "$useDefault" = "1" && -z $option ]] && [ ! "$option"  = "$option1" ] && [ ! "$option"  = "$option2" ]; do
      if [ ! -z "$5" ]; then
         if [ ! "$option" = "§" ]; then
            echo $5
         fi
      fi
      #echo -e "$1 ($labelDefault/$3)"
      read -p "$1 ($labelDefault/$3) " option
      option=$(tr '[:upper:]' '[:lower:]' <<< "$option" )
      echo $option
   done
}

#Usage function.
usage() {
  echo "
AVAPolos - Levando a educação a distância aonde a Internet não alcança
Uso: avapolos [OPÇÃO]
Comandos básicos:
  -h,  --help                  Mostra este texto de ajuda.
  -v,  --version               Mostra a versão da solução.
       --loglvl                Seleciona o nível de log (info|debug|warn|error).

Instalação:
       --install (-y)          Executa a instalação da solução.
       --uninstall (-y)        Executa a desinstalação da solução.

Operações básicas: (necessita instalar)
       --start (SERVIÇO.yml)   Inicia os serviços disponíveis.
       --stop (SERVIÇO.yml)    Para todos serviços disponíveis.
       --restart (SERVIÇO.yml) Reinicia todos os serviços.
  -b,  --backup (ARQUIVO)      Executa um backup do diretório de serviços.
  -r,  --restore (ARQUIVO)     Restaura um backup feito anteriormente.
       --export-all            Executa a clonagem da instalação.
       --access [ip/name]      Configura o acesso aos serviços.
"
}

#Shows the license.
showLicense() {
  echo "
  <AVAPolos - Uma solução tecnológica que possibilita o oferecimento de cursos na modalidade EaD (Educação a Distância) em locais sem conectividade com a Internet, ou onde a conectividade seja limitada.>
  Copyright (C) <2019>  <TI C3 - Centro de Ciências Computacionais / Universidade Federal do Rio Grande - FURG - Brazil>

  Este programa é um software livre: você pode redistribuí-lo e/ou
  modificá-lo sob os termos da Licença Pública Geral GNU, conforme
  publicado pela Free Software Foundation, seja a versão 3 da Licença
  ou (a seu critério) qualquer versão posterior.

  Este programa é distribuído na esperança de que seja útil,
  mas SEM QUALQUER GARANTIA; sem a garantia implícita de
  COMERCIALIZAÇÃO OU ADEQUAÇÃO A UM DETERMINADO PROPÓSITO. Veja a
  Licença Pública Geral GNU para obter mais detalhes.

  Você deve ter recebido uma cópia da Licença Pública Geral GNU
  junto com este programa. Se não, veja <https://www.gnu.org/licenses/>.
  "
}

#Installer function.
install() {
  if ! [ -d "$ROOT_PATH" ]; then

    #Log what script is being run.
    echo "-------------------- Instalando AVAPolos --------------------" | log info
    echo "Criando diretório de instalação." | log debug

    #Create the install dir.
    mkdir -p $ROOT_PATH

    #Check if the install archive is present.
    if ! [ -f "AVAPolos.tar.gz" ]; then
      echo "O arquivo 'AVAPolos.tar.gz' não foi encontrado, certifique-se que o mesmo se encontra nesse diretório: $PWD" | log error
      exit 1
    fi

    #Copying the install archive.
    echo "Copiando arquivos de instalação." | log debug
    cp $INSTALLER_DIR_PATH/AVAPolos.tar.gz $ROOT_PATH


    #Extract the install archive.
    cd $ROOT_PATH
    echo "Extraindo arquivos." | log debug
    tar xfz AVAPolos.tar.gz

    command="$INSTALL_SCRIPTS_PATH/install.sh $@"

    #sudo -H -u avapolos bash "$command"
    sudo bash -c "$command"
    exit 0
  else
    echo "Já existe uma instalação." | log error
    usage
    exit 0
  fi
}

#Uninstaller function.
uninstall() {
  case "$1" in
    -y)
    INTERACTIVE="n"
    ;;
    *)
    INTERACTIVE="y"
    ;;
  esac
  if [ -f "$INSTALL_SCRIPTS_PATH"/uninstall.sh ]; then
    cd $INSTALL_SCRIPTS_PATH
    bash uninstall.sh $@
    exit 0
  else
    option=$(input "O script de desinstalação não foi encontrado, deseja remover a instalação na força bruta?" "sim" "nao" 0 "Selecione uma opção.")
    if [ "$option" = "sim" ]; then
      rm -rf $ROOT_PATH
      echo "Diretório removido: $ROOT_PATH" | log debug
      exit 0
    fi
  fi
}

#Start the solution or a specific stack.
start() { #1 -> stack file: service.yml
if [ -d "$ROOT_PATH" ]; then
  cd $SCRIPTS_PATH
  echo "rodando script: $SCRIPTS_PATH/start.sh $@" | log debug
  bash $SCRIPTS_PATH/start.sh $@
else
  echo "AVAPolos não está instalado."
  exit 1
fi
}

#Stop the solution or a specific stack.
stop() { #1 -> stack file: service.yml
if [ -d "$ROOT_PATH" ]; then
  echo "rodando script: $SCRIPTS_PATH/stop.sh $@" | log debug
  bash $SCRIPTS_PATH/stop.sh $@
else
  echo "AVAPolos não está instalado."
  exit 1
fi
}

#Restart the solution or a specific stack.
restart() { #1 -> stack file: service.yml
if [ -d "$ROOT_PATH" ]; then
  echo "rodando script: $SCRIPTS_PATH/stop.sh $@" | log debug
  bash $SCRIPTS_PATH/stop.sh $@
  echo "rodando script: $SCRIPTS_PATH/start.sh $@" | log debug
  bash $SCRIPTS_PATH/start.sh $@
else
  echo "AVAPolos não está instalado."
  exit 1
fi
}

#Clone existing installation.
export_all() {
  if [ -d "$ROOT_PATH" ]; then
    cd $SYNC_PATH
    bash export_all.sh
  else
    echo "AVAPolos não está instalado." | log error
    exit 1
  fi
}

#Runs a specific script
run() { #$1-> script path #$@-> script's arguments
if [ -d "$ROOT_PATH" ]; then
  if ! [ -f "$1" ]; then
    echo "O script não foi encontrado: $1" | log error
    exit 1
  fi
  command="$1"
  shift
  command="$command $@"
  #sudo -H -u avapolos bash "$command"
  sudo bash -c "$command"
else
  echo "AVAPolos não está instalado."
  exit 1
fi
}

#Adds services to the startup stack.
add_service() { #$1 -> Service stack file
if [ -z "$1" ]; then
  echo "Usage: add_service [SERVICE]" | log error
  exit 1
fi
cd $SERVICES_PATH
echo "Adicinando serviço $1" | log debug
str=$(sanitize $1)
echo "$str" >> enabled_services
}

#Removes services from the startup stack.
remove_service() { #$1 -> Service stack file
if [ -z "$1" ]; then
  echo "Usage: remove_service [SERVICE]" | log error
  exit 1
fi
cd $SERVICES_PATH
echo "Removendo serviço $1" | log debug
str=$(sanitize $1)
sed -i '/'"$str"'/d' enabled_services
}

#Enables a service already installed.
enable_service() { #$1 -> service stack file: service.yml
if [ -z "$1" ]; then
  echo "Nenhum serviço foi passado para a enable_service" | log error
  exit 1
fi
arg="$1"
search=$(cat "$SERVICES_PATH/enabled_services" | grep -o "$arg" || true)
search_disabled=$(cat "$SERVICES_PATH/disabled_services" | grep -o "$arg" || true)
if ! [ -z "$search" ]; then
  echo "O serviço $arg já está habilitado!" | log error
elif ! [ -z "$search_disabled" ]; then
  sed -i '/'"$arg"'/d' "$SERVICES_PATH/disabled_services"
  echo "$arg" >> "$SERVICES_PATH/enabled_services"
else
  echo "O serviço $arg não está instalado!" | log error
  exit 1
fi

}

#Disables a service already installed.
disable_service() { #$1 -> service stack file: service.yml
if [ -z "$1" ]; then
  echo "Nenhum serviço foi passado para a disable_service" | log error
  exit 1
fi
#arg=$(sanitize $1)
arg="$1"
search=$(cat "$SERVICES_PATH/enabled_services" | grep -o "$arg" || true)
search_disabled=$(cat "$SERVICES_PATH/disabled_services" | grep -o "$arg" || true)
if ! [ -z "$search" ]; then
  sed -i '/'"$arg"'/d' "$SERVICES_PATH/enabled_services"
  echo "$arg" >> "$SERVICES_PATH/disabled_services"
elif ! [ -z "$search_disabled" ]; then
  echo "O serviço $arg já está desabilitado!" | log error
else
  echo "O serviço $arg não está instalado!" | log error
  exit 1
fi

}

#Undo configurations that start and end with "AVAPolos" in any file.
undoConfig() {
  if [ -z "$1" ]; then
    echo "Nenhum argumento foi passado para o undoConfig." | log error
    exit 1
  fi
  return=$(cat $1 | grep -no AVAPolos | cut -d: -f1)
  return=$(echo $return)
  line1=$(echo $return | awk '{print $1}')
  line2=$(echo $return | awk '{print $2}')
  str="$line1","$line2"\d
  sudo sed -i "$str" "$1"
}

#Execute a command in a container.
execute() {
  docker exec -it "$@"
  wait
  if [[ $? -ne 0 ]]; then
    echo "Ocorreu um erro no comando anterior, parando execução."
    exit 1
  fi
}

#Execute a SQL query in a moodle database.
execute_moodlesql() { #$1-> [db_moodle_ies,db_moodle_polo] #$2-> SQL Query
  eval "docker exec $1 psql -U moodle -d moodle -c \"$2\""
  if [[ $? -ne 0 ]]; then
    echo "Ocorreu um erro no comando anterior, parando execução."
    exit 1
  fi
}

#Execute sql in a avapolos database.
execute_sql() { #$1-> container #$2-> SQL Query
  eval "docker exec $1 psql -U moodle -c \"$2\""
  if [[ $? -ne 0 ]]; then
    echo "Ocorreu um erro no comando anterior, parando execução."
    exit 1
  fi
}

#Shows a env var
show_var() { #$1-> Variable name
  echo "$1: ${!1}"
}

#Waits for a container to be healthy
waitForHealthy() { #$1-> container
  while [ -z "$(docker container inspect --format='{{json .State.Health.Status}}' $1 | grep -o "healthy")" ]; do
    echo "Esperando a inicialização do $1"
    sleep 1
  done
}

#Tests a URL, exiting if it's not reachable
testURL() { #$1-> URL
  curl --fail \
      --retry-connrefuse \
      --connect-timeout 5 \
      --max-time 10 \
      --retry 5 \
      --retry-delay 0 \
      --retry-max-time 40 \
      -r 0-0 \
      "$1"
  if [[ $? -ne 0 ]]; then
    echo "A URL $1 não foi alcançada!"
    exit 1
  else
    echo "A URL $1 foi alcançada com sucesso!"
  fi
}

#Checks if a docker network exists, if not, adds it.
add_docker_network() { #$1-> Network name}
  if [[ "$(docker network inspect "$1" > /dev/null 2>&1 || true)" ]]; then
    docker network create "$1"
  fi
}

#Export all functions
export -f log
export -f greet
export -f sanitize
export -f input
export -f usage
export -f showLicense
export -f install
export -f uninstall
export -f start
export -f stop
export -f restart
export -f export_all
export -f run
export -f add_service
export -f remove_service
export -f enable_service
export -f disable_service
export -f undoConfig
export -f execute
export -f execute_moodlesql
export -f execute_sql
export -f show_var
export -f waitForHealthy
export -f testURL
export -f add_docker_network
