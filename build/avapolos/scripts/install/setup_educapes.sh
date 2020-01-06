#!/usr/bin/env bash

#Debugging
#set -x

#This script needs to run as root.
if [ "$EUID" -ne 0 ]; then
  echo "Este script precisa ser rodado como root" | log error installer
  exit
fi

#If the header file is present on the system.
if [ -f "/etc/avapolos/header.sh" ]; then
  #Source it.
  source /etc/avapolos/header.sh
#If it's not present.
else
  #Tell the user and exit with an error code.
  echo "Não foi encontrado o arquivo header.sh" | log error installer
  exit 1
fi

interrupt() {
  echo "Parando setup_educapes." | log debug installer
  pid=$(pgrep -f "wget --retry-connrefused --progress=dot:giga -c -t 0 -o")
  if ! [ -z "$pid" ]; then
    kill -9 $(pgrep -f "wget --retry-connrefused --progress=dot:giga -c -t 0 -o")
  fi
  echo "Removendo lock." | log debug installer
  rm -f $EDUCAPES_PATH/lock
  exit 0
}

die() {
  echo "Parando setup_educapes." | log debug installer
  exit 0
}

trap interrupt SIGTERM

echo "setup_educapes.sh" | log debug installer
echo "Instalando e configurando eduCAPES." | log info installer

PUID=$(id -u avapolos)
PGID=$(id -g avapolos)

main() {
  echo "main" | log debug installer

  if [ -f "$EDUCAPES_PATH/lock" ]; then
    echo "Há um script trabalhando neste diretório!" | log error installer
    die
  fi

  echo "Checando conexão com a CAPES." | log debug installer
  ping -4 -c 1 -W 10 uploads.capes.gov.br > /dev/null 2>&1
  if [ "$?" == "0" ]; then
    echo "Servidor da CAPES alcançado." | log debug installer
    mkdir -p $EDUCAPES_PATH/download
    chown $PUID:$PGID $EDUCAPES_PATH -R
    touch $EDUCAPES_PATH/lock

    stop "educapes.yml"
    disable_service "educapes.yml"

    download
    extract

    echo "Download e extração concluídos." | log debug installer
    echo "Subindo serviço e reidexando conteúdos." | log debug installer

    enable_service "educapes.yml"
    start "educapes.yml"

    reindex

    echo "eduCAPES configurado." | log debug installer
    rm $EDUCAPES_PATH/lock

    touch $EDUCAPES_PATH/setup_done

  else
    echo "Não foi possível alcançar o servidor da CAPES" | log error installer
  fi
}

download() {
  echo "download" | log debug installer
  cd $EDUCAPES_PATH/download
  if ! [ -f "download_done" ]; then
    echo "Iniciando download dos arquivos do educapes" | log debug installer
    parts="http://uploads.capes.gov.br/files/volumesEducapes.part01.rar http://uploads.capes.gov.br/files/volumesEducapes.part02.rar http://uploads.capes.gov.br/files/volumesEducapes.part03.rar http://uploads.capes.gov.br/files/volumesEducapes.part04.rar http://uploads.capes.gov.br/files/volumesEducapes.part05.rar http://uploads.capes.gov.br/files/volumesEducapes.part06.rar http://uploads.capes.gov.br/files/volumesEducapes.part07.rar http://uploads.capes.gov.br/files/volumesEducapes.part08.rar http://uploads.capes.gov.br/files/volumesEducapes.part09.rar"
  	echo "Baixando arquivos: $parts" | log debug installer
  	wget --retry-connrefused --progress=dot:giga -c -t 0 -o "wget-log" $parts &
    wait
    echo "Download do eduCAPES finalizado." | log debug installer
    touch download_done
  else
    echo "Download já está completo." | log debug installer
  fi
}

extract() {
  echo "unrar" | log debug installer
  if ! [ -f "$EDUCAPES_PATH/unrar_done" ]; then
    echo "Assegurando permissões corretas" | log debug installer
    cd $EDUCAPES_PATH/download
    chown $PUID:$PGID $EDUCAPES_PATH -R
    echo "Executando unrar." | log debug installer
    unrar x -o+ "volumesEducapes.part01.rar" | log debug installer
    echo "unrar executado com sucesso." | log debug installer
    rm -rf ../{assetstore,data-solr,database}
    mv -f assetstore ..
    mv -f data-solr ..
    mv -f database ..
    touch ../unrar_done
  else
    echo "Já está descompactado." | log debug installer
  fi
}

reindex() {
  echo "reindex" | log debug installer
  echo "Limpando índices do educapes" | log debug installer
  docker exec educapes /dspace/bin/dspace index-discovery -c -f
  echo "Reindexando educapes, tempo estimado: 40min" | log debug installer
  docker exec educapes /dspace/bin/dspace index-discovery -f
  echo "Reindexação completa." | log debug installer
}

main
