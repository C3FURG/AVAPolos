#!/usr/bin/env bash

source /etc/avapolos/header.sh
source $SYNC_PATH/variables.sh
source $SYNC_PATH/functions.sh

log debug "restore.sh" 

if ! [ -z "$1" ]; then

  filePath="$1"
  if [ -z "$(echo $filePath | grep -o "/")" ]; then
    filePath="$BACKUPS_PATH/$filePath"
  fi

  if [ -f "$filePath" ]; then

    if [[ $1 =~ moodle ]]; then
      stop moodle.yml
      rm -rf $DATA_PATH/{moodle/moodledata/filedir,db_moodle_ies,db_moodle_polo}
      rm -rf $SYNC_PATH/{Export,Import,dadosExportados}
      tar xfzv "$1" -C /
      start moodle.yml
    else
      stop
      rm -rf $DATA_PATH
      tar xfzv "$1" -C /
      start
    fi
  else
    echo "O arquivo $filePath não existe."
  fi
fi

# stopMoodle
# stopDBMaster
# stopDBSync
#
# rm -rf $DATA_PATH/$dataDirMaster $DATA_PATH/$dataDirSync $DATA_PATH/moodle/moodledata/filedir $SYNC_PATH/Export/ $SYNC_PATH/Import/* $SYNC_PATH/dadosExportados/
# tar xzf "$1"
#
# chown $AVAPOLOS_USER:$AVAPOLOS_GROUP $DATA_PATH
# chown $AVAPOLOS_USER:$AVAPOLOS_GROUP $SYNC_PATH
#
# startMoodle
# startDBMaster
