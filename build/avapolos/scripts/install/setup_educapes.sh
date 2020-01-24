#!/usr/bin/env bash

#Debugging
#set -x

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

interrupt() {
  echo "Parando setup_educapes." | log debug setup_educapes
  echo "Removendo lock." | log debug setup_educapes
  rm -f $EDUCAPES_PATH/lock
}

trap interrupt SIGTERM

echo "setup_educapes.sh" | log debug setup_educapes
echo "Instalando e configurando eduCAPES." | log info setup_educapes

PUID=$(id -u avapolos)
PGID=$(id -g avapolos)

main() {
  mkdir -p $EDUCAPES_PATH
  cd $EDUCAPES_PATH

  if ! [ -f "no_check" ] && ! [ -f "setup_done" ]; then
    if [ -f "$EDUCAPES_PATH/lock" ]; then
      echo "Há um script trabalhando neste diretório!" | log error setup_educapes
    else
      echo "Checando conexão com a CAPES." | log debug setup_educapes
      ping -4 -c 1 -W 10 uploads.capes.gov.br > /dev/null 2>&1
      if [ "$?" == "0" ]; then
        echo "Servidor da CAPES alcançado." | log debug setup_educapes
        mkdir -p $EDUCAPES_PATH/download
        chown $PUID:$PGID $EDUCAPES_PATH -R
        touch $EDUCAPES_PATH/lock

        stop "educapes.yml"
        disable_service "educapes.yml"

        download
        extract

        echo "Download e extração concluídos." | log debug setup_educapes
        echo "Subindo serviço e reidexando conteúdos." | log debug setup_educapes

        enable_service "educapes.yml"
        start "educapes.yml"

        reindex

        echo "eduCAPES configurado." | log debug setup_educapes
        rm $EDUCAPES_PATH/lock
        touch $EDUCAPES_PATH/setup_done
      else
        echo "Não foi possível alcançar o servidor da CAPES" | log error setup_educapes
      fi
    fi

  else
    echo "eduCAPES service is already set up or it's disabled." | log info
  fi

}

download() {
  echo "download" | log debug setup_educapes
  cd $EDUCAPES_PATH/download
  if ! [ -f "download_done" ]; then
    echo "Iniciando download dos arquivos do educapes" | log debug setup_educapes
    parts="http://uploads.capes.gov.br/files/volumesEducapes.part01.rar http://uploads.capes.gov.br/files/volumesEducapes.part02.rar http://uploads.capes.gov.br/files/volumesEducapes.part03.rar http://uploads.capes.gov.br/files/volumesEducapes.part04.rar http://uploads.capes.gov.br/files/volumesEducapes.part05.rar http://uploads.capes.gov.br/files/volumesEducapes.part06.rar http://uploads.capes.gov.br/files/volumesEducapes.part07.rar http://uploads.capes.gov.br/files/volumesEducapes.part08.rar http://uploads.capes.gov.br/files/volumesEducapes.part09.rar"
  	echo "Baixando arquivos: $parts" | log debug setup_educapes
  	wget --retry-connrefused --progress=dot:giga -c -t 0 -o "wget-log" $parts
    echo "Download do eduCAPES finalizado." | log debug setup_educapes
    touch download_done
  else
    echo "Download já está completo." | log debug setup_educapes
  fi
}

extract() {
  echo "unrar" | log debug setup_educapes
  if ! [ -f "$EDUCAPES_PATH/unrar_done" ]; then
    echo "Assegurando permissões corretas" | log debug setup_educapes
    cd $EDUCAPES_PATH/download
    chown $PUID:$PGID $EDUCAPES_PATH -R
    echo "Executando unrar." | log debug setup_educapes
    unrar x -o+ "volumesEducapes.part01.rar" | log debug setup_educapes
    echo "unrar executado com sucesso." | log debug setup_educapes
    rm -rf ../{assetstore,data-solr,database}
    mv -f assetstore ..
    mv -f data-solr ..
    mv -f database ..
    touch ../unrar_done
  else
    echo "Já está descompactado." | log debug setup_educapes
  fi
}

reindex() {
  echo "reindex" | log debug setup_educapes
  echo "Limpando índices do educapes" | log debug setup_educapes
  docker exec educapes /dspace/bin/dspace index-discovery -c -f
  echo "Reindexando educapes, tempo estimado: 40min" | log debug setup_educapes
  docker exec educapes /dspace/bin/dspace index-discovery -f
  echo "Reindexação completa." | log debug setup_educapes
}

main
