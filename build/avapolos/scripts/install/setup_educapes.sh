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
  log debug "Parando setup_educapes." 
  log debug "Removendo lock." 
  rm -f $EDUCAPES_PATH/lock
}

trap interrupt SIGTERM

log debug "setup_educapes.sh" 
log info "Instalando e configurando eduCAPES." 

PUID=$(id -u avapolos)
PGID=$(id -g avapolos)

main() {
  mkdir -p $EDUCAPES_PATH
  cd $EDUCAPES_PATH

  if ! [ -f "no_check" ] && ! [ -f "setup_done" ]; then
    if [ -f "$EDUCAPES_PATH/lock" ]; then
    log error "Há um script trabalhando neste diretório!" 
    else
      log debug "Checando conexão com a CAPES." 
      ping -4 -c 1 -W 10 uploads.capes.gov.br > /dev/null 2>&1
      if [ "$?" == "0" ]; then
        log debug "Servidor da CAPES alcançado." 
        mkdir -p $EDUCAPES_PATH/download
        chown $PUID:$PGID $EDUCAPES_PATH -R
        touch $EDUCAPES_PATH/lock

        stop "educapes.yml"
        disable_service "educapes.yml"

        download
        extract

        log debug "Download e extração concluídos." 
        log debug "Subindo serviço e reidexando conteúdos." 

        enable_service "educapes.yml"
        start "educapes.yml"

        reindex

        log debug "eduCAPES configurado." 
        rm $EDUCAPES_PATH/lock
        touch $EDUCAPES_PATH/setup_done
      else
        log error "Não foi possível alcançar o servidor da CAPES" 
      fi
    fi

  else
  log info "eduCAPES service is already set up or it's disabled." 
  fi

}

download() {
  log debug  "download" 
  cd $EDUCAPES_PATH/download
  if ! [ -f "download_done" ]; then
    log debug "Iniciando download dos arquivos do educapes" 
    parts="http://uploads.capes.gov.br/files/volumesEducapes.part01.rar http://uploads.capes.gov.br/files/volumesEducapes.part02.rar http://uploads.capes.gov.br/files/volumesEducapes.part03.rar http://uploads.capes.gov.br/files/volumesEducapes.part04.rar http://uploads.capes.gov.br/files/volumesEducapes.part05.rar http://uploads.capes.gov.br/files/volumesEducapes.part06.rar http://uploads.capes.gov.br/files/volumesEducapes.part07.rar http://uploads.capes.gov.br/files/volumesEducapes.part08.rar http://uploads.capes.gov.br/files/volumesEducapes.part09.rar"
  	log debug "Baixando arquivos: $parts"
  	wget --retry-connrefused --progress=dot:giga -c -t 0 -o "wget-log" $parts
    log debug "Download do eduCAPES finalizado." 
    touch download_done
  else
    log debug "Download já está completo." 
  fi
}

extract() {
  log debug  "unrar" 
  if ! [ -f "$EDUCAPES_PATH/unrar_done" ]; then
    log debug "Assegurando permissões corretas" 
    cd $EDUCAPES_PATH/download
    chown $PUID:$PGID $EDUCAPES_PATH -R
    log debug "Executando unrar." 
    log debug $(unrar x -o+ "volumesEducapes.part01.rar")
    log debug "unrar executado com sucesso." 
    rm -rf ../{assetstore,data-solr,database}
    mv -f assetstore ..
    mv -f data-solr ..
    mv -f database ..
    touch ../unrar_done
  else
    log debug "Já está descompactado." 
  fi
}

reindex() {
  log debug "reindex" 
  log debug "Limpando índices do educapes" 
  docker exec educapes /dspace/bin/dspace index-discovery -c -f
  log debug "Reindexando educapes, tempo estimado: 40min"
  docker exec educapes /dspace/bin/dspace index-discovery -f
  log debug "Reindexação completa." 
}

main
