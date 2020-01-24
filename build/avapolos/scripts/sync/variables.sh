#!/usr/bin/env bash

source /etc/avapolos/header.sh

#SYNC VARIABLES
remoteServerAddress="0.0.0.0"

instance="INSTANCENAME" #possible values: IES | POLO # CASE SENSITIVE!!!
containerPoloName="db_moodle_polo"
containerIESName="db_moodle_ies"
containerMoodleName="moodle"
containerWikiName="wiki"
containerDBWikiName="db_wiki"
containerBackupName="backup"
containerDSPaceName="educapes"
containerDBDSPaceName="dspacedb"
containerHubName="hub"
containerTraefikName="traefik"
containerDownloadsName="downloads"

dirPath=$ROOT_PATH
configPath="$dirPath/scripts/sync/config.txt"
archiveExportPath="$dirPath/scripts/sync/dadosExportados"
dirExportRoot="$dirPath/scripts/sync/Export"
dirExportPath="$dirExportRoot/scripts/sync/Fila"
dirImportPath="$dirPath/scripts/sync/Import"
dirViewPath="$dirPath/data/moodle/public/admin/tool/avapolos/view"
moodleDataDirPath="$dirPath/data/moodle/moodledata"
fileDirPath="$moodleDataDirPath/filedir"
repoDirPath="$moodleDataDirPath/repository/avapolos"
syncFileDirListPath="$dirExportRoot/syncFileDirList"
masterFileDirListPath="$dirExportRoot/masterFileDirList"

### VARIABLES SET AUTOMATICALLY - DO NOT TOUCH THEM
if [ "$instance" = "POLO" ]; then
   dataDirMaster="db_moodle_polo";
   dataDirSync="db_moodle_ies";
   containerDBMasterName=$containerPoloName
   containerDBSyncName=$containerIESName
   complement="IES"
elif [ "$instance" = "IES" ]; then
   dataDirMaster="db_moodle_ies";
   dataDirSync="db_moodle_polo";
   containerDBMasterName=$containerIESName
   containerDBSyncName=$containerPoloName
   complement="POLO"
fi

### END

dirDBMaster="$dirPath/data/$dataDirMaster"
dirDBSync="$dirPath/data/$dataDirSync"
dirLogPathMaster="$dirDBMaster/pg_log"
dirLogPathSync="$dirDBSync/pg_log"


lastExport=0
nextExport=0
lastImport=0
exportDirName=""

alias conm="docker exec -it $containerDBMasterName psql -U moodle -d moodle"
alias cons="docker exec -it $containerDBSyncName   psql -U moodle -d moodle"
