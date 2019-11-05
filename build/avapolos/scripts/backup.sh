#!/bin/bash

source /etc/avapolos/header.sh
source $SYNC_PATH/variables.sh
source $SYNC_PATH/functions.sh

echo "backup.sh" | log debug

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
    *)
      break
    ;;
  esac
done

start=$(date +%s)

case "$service" in
  moodle )
    echo "Parando serviço." | log debug
    stop moodle.yml
    echo "Compactando backup." | log debug
    tar --use-compress-program="pigz -9" -cf "$path/$label.tar.gz" $DATA_PATH/$dataDirMaster $DATA_PATH/$dataDirSync $DATA_PATH/moodle/moodledata/filedir $SYNC_PATH/Export/ $SYNC_PATH/Import/ $SYNC_PATH/dadosExportados/
    echo "Iniciando serviço." | log debug
    start moodle.yml
  ;;

  *)
  echo "Parando serviços." | log debug
  stop
  echo "Compactando backup." | log debug
  tar --use-compress-program="pigz -9" -cf "$path/$label.tar.gz" $DATA_PATH
  echo "Iniciando serviços." | log debug
  start
  ;;
esac

end=$(date +%s)

runtime=$((end-start))

echo "Backup concluído."
echo "Arquivo de backup disponível em: $path/$label'.tar.gz'" | log info
echo "Tamanho: $(du -h $path/$label'.tar.gz' | awk {'print $1'})" | log info
echo "Em "$runtime"s." | log info

# source $SYNC_PATH/variables.sh
# source $SYNC_PATH/functions.sh
# stopMoodle
# stopDBMaster
# stopDBSync
#
# echo "Creating Backup: $1" | log debug
#
# tar cfz "$1" $DATA_PATH/$dataDirMaster $DATA_PATH/$dataDirSync $DATA_PATH/moodle/moodledata/filedir $SYNC_PATH/Export/ $SYNC_PATH/Import/ $SYNC_PATH/dadosExportados/
#
# startMoodle
# startDBMaster
