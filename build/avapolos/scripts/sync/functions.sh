#!/usr/bin/env bash

## FIXME
if [ -f "/etc/avapolos/header.sh" ]; then
  source /etc/avapolos/header.sh
fi

#---------------------------------------------------------------

restartMoodle(){
   stopMoodle
   startMoodle
}

startMoodle(){
    echo "Iniciando Moodle" | log debug sync
    startContainer $containerMoodleName
    ip=$(bash $INSTALL_SCRIPTS_PATH/get_ip.sh)
    echo "Atualizando hosts do Moodle com o IP: $ip" | log debug sync
    docker exec $containerMoodleName sh -c "echo \"$ip avapolos\" >> /etc/hosts"
    echo "Moodle inicializado" | log debug sync
}

stopMoodle(){
    echo "Parando Moodle" | log debug sync
    stopContainer $containerMoodleName
    echo "Moodle Parado" | log debug sync
}

startDBMaster(){
    echo "Iniciando db_master" | log debug sync
    startContainer $containerDBMasterName
    sleep 3
    #waitForHealthy $containerDBMasterName
    echo "db_master inicializado" | log debug sync
}

stopDBMaster(){
    echo "-> Stopping container DB_MASTER..."
    stopContainer $containerDBMasterName
    echo "-----> DOCKER DB_MASTER | STATUS = [OFF]"
}

startDBSync(){
    echo "-> Starting container DB_SYNC..."
    startContainer $containerDBSyncName
    sleep 3
    #waitForHealthy $containerDBSyncName
    echo "----> DOCKER DB_SYNC | STATUS = [ON]"
}

stopDBSync(){
    echo "-> Stopping container DB_SYNC..."
    stopContainer $containerDBSyncName
    echo "----> DOCKER DB_SYNC | STATUS = [OFF]"
}

connectDB() { #$1-> [db_moodle_ies/db_moodle_polo]
  docker exec -it "$1" psql -U moodle -d moodle
}

#-------------------------------------------------------------------------------------------------

stopContainer(){ #container
    echo "Parando container $1" | log debug sync
    docker stop $1
    while [ "$(docker inspect -f '{{.State.Running}}' $1)" == true ]; do
      sleep 5 #10 seconds
    done
    echo "Container $1 parado" | log debug sync
}

startContainer(){ #container
    echo "Iniciando container $1" | log debug sync
    docker start $1
    while [ "$(docker inspect -f '{{.State.Running}}' $1)" == false ]; do
      sleep 5
    done
    echo "Container $1 inicializado" | log debug sync
}

clearQueue(){ # aguarda o master enviar as alterações
   echo " ==================== LIMPANDO FILA DE SINCRONIZAÇÃO | STATUS = [INICIALIZANDO]"
   startDBMaster
   startDBSync

   waitSyncEndSync

   stopDBSync #parar instância de sincronização
   echo "----> LIMPANDO FILA DE SINCRONIZAÇÃO | STATUS = [FINALIZADA]"
}

startSync(){ #$1 = versao da importacao sendo feita
   echo " ==================== Sincronização | STATUS = [INICIALIZANDO]"
   bdrPauseMasterSync # this method stops DBMaster and starts DBSync

   startDBMaster

   waitSyncEndMaster

   stopDBSync #parar instância de sincronização
   echo "----> Sincronização | STATUS = [FINALIZADA]"
}

waitSyncEnd(){ #$1 = nome do container do banco que precisa esperar as operações serem enviadas para o outro nodo;
   echo " ==================== Aguardando sincronização | STATUS = [EM ANDAMENTO]"
   execSQL $1 "select bdr.wait_slot_confirm_lsn(NULL, NULL)"
}

waitSyncEndMaster(){ #wait for DBMaster to be synchronized with DBSync (to receive all operations DBSync has to send)
   waitSyncEnd $containerDBSyncName
}

waitSyncEndSync(){ #wait for DBSync to be synchronized with DBMaster (to receive all operations DBMaster has to send)
   waitSyncEnd $containerDBMasterName
}

copyExportFiles(){ # $1 = indicate where to save the exported files
    exportDir="$dirExportPath/$1"
    exportDirFiles="$exportDir/arquivos/filedir"
    exportDirDb="$exportDir/database"
    exportDirFileList="$exportDir/filedirList"

    echo " -> Copiando arquivos...."

    if [ -e "$exportDir" ]; then
       labelData=$(date -u "+%Y%m%d%H%M%S")
       echo " -> Diretório $exportDir já existe, criando backup com o nome $dirExportPath/${1}_CONFLICT_$labelData ..."
       mv $exportDir $dirExportPath/${$1}_CONFLICT_$labelData
       echo " ---> ...backup criado. Diretório $dirExportPath/${$1}_CONFLICT_$labelData"
    fi

    mkdir -p "$exportDirFiles" "$exportDirDb" "$exportDirFileList"

    copyDbFiles $exportDirDb #copy database files to the exportDatabaseDir
    copyDiffFileDir $exportDirFiles #copy moodledata/filedir to the exportFileDir
    createFileDirList $exportDirFiles $syncFileDirListPath

    echo " ----> ...arquivos copiados."
}

createExportFile(){
   nameTar=$1
   mkdir -p $archiveExportPath
   echo " -> Gerando arquivo de exportação..."
   cd $dirExportPath
   tar -cpzf "$nameTar" * && cd $dirPath
   echo " ----> ...arquivo gerado."

   lastImportSync=$(getLastImportSync)
   exportFrom=$(( $lastImportSync  + 1))
   lastExport=$(getLastExportMaster)

   echo " -----> Última importação realizada no servidor $complement = $lastImportSync "
   echo " -----> Realizando a exportação da versão $exportFrom até a versão $lastExport "
   strTar=""
   i=1
   while [ $i -le $lastExport ]; do
      if [ $i -ge $exportFrom ];then #if it was not imported yet, put the file on the queue
         strTar="$strTar dadosV_${i}_$instance.tar.gz "
      else #otherwise remove it
         if [ -f $archiveExportPath/dadosV_${i}_$instance.tar.gz ]; then
            rm $archiveExportPath/dadosV_${i}_$instance.tar.gz;
         fi
      fi
      let i=i+1
   done
   cd $archiveExportPath;
   nameTar=$(basename $nameTar)
   tar cvzf $dirViewPath/$nameTar $strTar

}

changeDBSync(){
   importDir=$1
   echo "-> REMOVING DB_SYNC..."
   rm -rf "$dirPath/data/$dataDirSync" # the sync database dir, it depends whether it is IES or polo
   while [ -e $dirPath/data/$dataDirSync ];
   do
      echo "Aguardando exclusao de DB_SYNC";
      sleep 5
   done
   echo "------> DB_SYNC removed."

   echo "-> COPYING DB_SYNC FROM THE IMPORT FILE..."
   cp -R "$dirImportPath/$importDir/database/$dataDirSync" "$dirPath/data/${dataDirSync}STAGE" && mv "$dirPath/data/${dataDirSync}STAGE" "$dirPath/data/$dataDirSync"
   echo "-------> NEW DB_SYNC COPIED."
}

createControlRecord(){ #$1 = versao da sincronização sendo exportado ou importado; $2 = tipo de operação (C=clonagem, E=export, I=import) $3 = usuario realizando operação
	ret=$(execSQLMaster "INSERT INTO avapolos_sync (instancia,versao,tipo,moodle_user) VALUES ('$instance',$1,'$2','$3');")
	res=$(echo $ret | grep "INSERT 0 1")
	if [ -z "$res" ]; then
		echo "ERRO AO CRIAR REGISTRO DE CONTROLE"
		echo " -----> INSERT INTO avapolos_sync (instancia,versao,tipo,moodle_user) VALUES ('$instance',$1,'$2','$3');"
   	echo "ERROR: $ret"
		exit
	else
		echo "REGISTRO DE CONTROLE CRIADO COM SUCESSO"
	fi
}

createFileDirList(){ # $1 = sourceFileDir $2 = fileDirListPath
   sourceFileDir=$1
   fileDirListPath=$2
   if [ ! -e $fileDirListPath ]; then
      mkdir -p $fileDirListPath
   fi
   for file in $(find $sourceFileDir | grep -Eo '([a-f0-9]{2}/){2}([a-f0-9]){40}$'); do namedir=$fileDirListPath/$(dirname $file); mkdir $namedir -p; touch $namedir/$(basename $file); done

}

createSyncFileDirList(){ #this function is used only when the clone is done, when the master knows that the syncFileDir is exactly the same as the masterFileDir
   createFileDirList $fileDirPath $syncFileDirListPath
}

copySyncFileDirList(){ #$1 = ImportSyncFileDirListPath
   if [ -e $syncFileDirListPath ]; then
      rm $syncFileDirListPath -rf;
      mkdir -p $syncFileDirListPath ;
      cp -r $1/* $syncFileDirListPath;
   fi
}

createMasterFileDirList(){
   createFileDirList $fileDirPath $masterFileDirListPath
}

copyDbFiles(){ #$1 = exportDir/database
   cp -rf "$dirPath/data/$dataDirMaster/" $1
}

copyDiffFileDir(){ #$1 exportFileDir (use absolutePath!!!)
    exportFileDir=$1
    if [ ! -e $syncFileDirListPath ]; then
       mkdir -p $syncFileDirListPath
    fi
    createMasterFileDirList
    for file in $(diff -rq $masterFileDirListPath $syncFileDirListPath | grep $masterFileDirListPath | cut -d" " -f3,4 | sed -e 's/: /\//g'); do
       echo $file
       fileSourcePath=$(echo $file | sed -e "s/$(escapePath $masterFileDirListPath)/$(escapePath $fileDirPath)/g")
       destPath=$(echo $file | sed -e "s/$(escapePath $masterFileDirListPath)/$(escapePath $exportFileDir)/g")
       nameFile=$(basename $destPath)
       destPath=$(dirname $destPath)
       mkdir -p $destPath;
       cp -vr $fileSourcePath $destPath/;
    done
}

escapePath(){
   echo $1 | sed -e 's/\//\\\//g'
}

bdrPauseSync(){ #$1 = container name
  echo " =====> PAUSANDO A SINCRONIZAÇÃO. Banco $1 não irá receber operações de sincronização..."
  execSQL $1 "select bdr.bdr_apply_pause();"
  ret=$(execSQL $1 'select bdr.bdr_apply_is_paused();' | sed -n 3p | grep f -o)
  while [ "$ret" = "f" ]; do
     sleep 3;
     ret=$(execSQL $1 'select bdr.bdr_apply_is_paused();' | sed -n 3p | grep f -o)
  done
  echo " -----------> pausada."
}

bdrResumeSync(){
   echo " =====> Reestabelecendo a sincronização. Banco $1 voltará a receber operações de sincronização..."
   execSQL $1 "select bdr.bdr_apply_resume();"
   ret=$(execSQL $1 'select bdr.bdr_apply_is_paused();' | sed -n 3p | grep f -o)
   while [ "$ret" = "t" ]; do
      sleep 3;
      ret=$(execSQL $1 'select bdr.bdr_apply_is_paused();' | sed -n 3p | grep f -o)
   done
   echo " -----------> reestabelecida."
}

bdrPauseMasterSync(){ # DBSync pause receiving sync operations from DBMaster
   stopDBMaster
   startDBSync
   bdrPauseSync $containerDBSyncName
}

#bdrPauseSyncSync(){ # DBMaster pause receiving sync operations from DBSync
   #stopDBSync
   #startDBMaster
   #bdrPauseSync $containerDBMasterName                       #NOT NECESSARY SO FAR - UNCOMMENT AND CHECK IMPLEMENTATION BEFORE USE
#}

bdrResumeMasterSync(){ # DBSync resume receiving sync operations from DBMaster
   stopDBMaster
   startDBSync
   bdrResumeSync $containerDBSyncName
   stopDBSync
   startDBMaster
}

#bdrResumeSyncSync(){ # DBMaster resume receiving sync operations from DBSync
   #stopDBSync
   #startDBMaster
   #bdrResumeSync $containerDBMasterName                       #NOT NECESSARY SO FAR - UNCOMMENT AND CHECK IMPLEMENTATION BEFORE USE
#}

execDockerCommand(){ # $1=container  $2=command
   eval "docker exec $1 $2"
}

execSQL(){ # $1 = containerName $2 SQL statement
   execDockerCommand $1 "psql -U moodle -d moodle -c \"$2\""
}

execSQLMoodle(){ # $1 = containerName $2 SQL statement
   execDockerCommand $1 "psql -U moodleuser -d moodle -c \"$2\""
}

execSQLMaster(){ # $1 SQL statement
   execSQL $containerDBMasterName "$1"
}

execSQLSync(){ # $1 SQL statement
   execSql $containerDBSyncName "$1"
}

treatRet(){
   ret=$(echo $1 | tr '\n' ' ')
   if [ "$ret" = ' ' ]; then
      ret=0;
   fi
   echo $(($ret));
}

getLastImportMaster(){
   ret=$(execSQLMaster "SELECT max(versao) FROM avapolos_sync WHERE INSTANCIA='$instance' AND TIPO='I';" | sed -n 3p | sed -e "s/[[:space:]]//g")
   echo $(treatRet $ret);
}

getLastExportMaster(){
   echo $(execSQLMaster "SELECT max(versao) FROM avapolos_sync WHERE INSTANCIA='$instance' AND TIPO='E';" | sed -n 3p | sed -e "s/[[:space:]]//g")
}

getLastImportSync(){
   ret=$(execSQLMaster "SELECT max(versao) FROM avapolos_sync WHERE INSTANCIA='$complement' AND TIPO='I';" | sed -n 3p | sed -e "s/[[:space:]]//g")
   echo $(treatRet $ret);
}

getLastExportSync(){
   echo $(execSQLMaster "SELECT max(versao) FROM avapolos_sync WHERE INSTANCIA='$complement' AND TIPO='E';" | sed -n 3p | sed -e "s/[[:space:]]//g")
}

clearExportDir(){
   if [ -e $dirExportPath ]; then
      rm $dirExportPath/* -r
   fi
}

clearImportDir(){ # $1 = diretorio que contem database, filedir e filedirList - possui o mesmo nome do tar.gz
   echo "=====> Apagando arquivos $1"
   if [ -e $dirImportPath/$1 ]; then
      rm $dirImportPath/$1 -r
   fi
   if [ -f $dirImportPath/$1.tar.gz ]; then
      rm $dirImportPath/$1.tar.gz
   fi
   if [ -f $repoDirPath/$1.tar.gz ]; then
      rm $repoDirPath/$1.tar.gz;
   fi
}

findControlRecord(){ #$1 = instancia $2= versao da operação $3 = tipo da operação
    if [ $(execSQLMaster "SELECT count(*) FROM avapolos_sync WHERE INSTANCIA='$1' AND VERSAO=$2 AND TIPO='$3';" | sed -n 3p | sed -e "s/[[:space:]]//g") = "1" ]; then
      echo 1;
   else
      echo 0;
   fi
}

copyFileToRemoteRepo(){ # $1 = nameFile ### the two machines need to be have pairs of keys exchanged
   scp "$1" "avapolos@$remoteServerAddress:$repoDirPath"
   echo $?
}

export -f execSQL
export -f execSQLMoodle
export -f execDockerCommand
export -f connectDB
