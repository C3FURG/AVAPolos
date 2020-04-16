#!/usr/bin/env bash

source /etc/avapolos/header.sh
source $SYNC_PATH/variables.sh
source $SYNC_PATH/functions.sh

log debug "backup.sh" 

#Backup filename generation.
timestamp="$(date +%D | sed 's/\//\./g')"
type=""
if [ -f $INSTALL_SCRIPTS_PATH/polo ]; then
  type="POLO"
else
  type="IES"
fi

label="backup-"$type"-"$timestamp
number=""

while [ -f "$BACKUPS_PATH/$label.tar.gz" ]; do
  if [ -z $(echo $label | grep -o "~") ]; then
    number=1
    label=$label"~1"
  else
    number=$(echo $label | cut -d~ -f2)
    number=$(($number + 1))
    label="$(echo $label | cut -d~ -f1)~$number"
  fi
done

path=$BACKUPS_PATH
service="all"

while true; do
  case "$1" in
    --path )
      shift
      path=$1
      shift
    ;;
    --service )
    shift
      service=$1
      label=$label-$service
      shift
    ;;
    -h )
      echo "--service, --path"
    ;;
    *)
      break
    ;;
  esac
done

start=$(date +%s)

case "$service" in
  moodle )
  log debug "Parando serviço." 
  stop moodle.yml
  log debug "Compactando backup." 
  tar --use-compress-program="pigz -9" -cf "$path/$label.tar.gz" $DATA_PATH/$dataDirMaster $DATA_PATH/$dataDirSync $DATA_PATH/moodle/moodledata/filedir $SYNC_PATH/Export/ $SYNC_PATH/Import/ $SYNC_PATH/dadosExportados/
  log debug "Iniciando serviço." 
  start moodle.yml
  ;;

  *)
  log debug "Parando serviços." 
  stop
  log debug "Compactando backup." 
  tar --use-compress-program="pigz -9" -cf "$path/$label.tar.gz" $DATA_PATH
  log debug "Iniciando serviços." 
  start
  ;;
esac

end=$(date +%s)

runtime=$((end-start))

log info "Backup concluído."
log info "Arquivo de backup disponível em: $path/$label'.tar.gz'"
log info "Tamanho: $(du -h $path/$label'.tar.gz' | awk {'print $1'})"
log info "Em "$runtime"s." 

# source $SYNC_PATH/variables.sh
# source $SYNC_PATH/functions.sh
# stopMoodle
# stopDBMaster
# stopDBSync
#
# echo "Creating Backup: $1"
#
# tar cfz "$1" $DATA_PATH/$dataDirMaster $DATA_PATH/$dataDirSync $DATA_PATH/moodle/moodledata/filedir $SYNC_PATH/Export/ $SYNC_PATH/Import/ $SYNC_PATH/dadosExportados/
#
# startMoodle
# startDBMaster
