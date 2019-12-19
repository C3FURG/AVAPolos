#!/usr/bin/env bash
# PROJETO
#     _                      ____            _
#    / \    __   __   __ _  |  _ \    ___   | |   ___    ___
#   / _ \   \ \ / /  / _` | | |_) |  / _ \  | |  / _ \  / __|
#  / ___ \   \ V /  | (_| | |  __/  | (_) | | | | (_) | \__ \
# /_/   \_\   \_/    \__,_| |_|      \___/  |_|  \___/  |___/
# UNIVERSIDADE FEDERAL DO RIO GRANDE - RS

option=$1   # 1=export; 2=import; 4=exit;
username=$2


if [ ! "$option" = "1" ] && [ ! "$option" = "2" ] && [ ! "$option" = "3" ]; then
  echo "Usage: sync.sh option moodleUser [tarPath];
           --> option = 1 to export or 2 to import."
  exit 1
fi

source variables.sh
source functions.sh
errorStatus=0
#remove a flag de finalização caso ela já exista
[ -e $dirViewPath/syncFinalizada ] && $( rm $dirViewPath/syncFinalizada )

if [ "$option" = "1" ] || [ "$option" = "3" ]; then
   echo " ================= INICIANDO PROCESSO DE EXPORTAÇÃO =================\n"

   ###limpa arquivos tar anteriores
   rm -f $dirViewPath/dadosV*.tar.gz

   nextExport=$(( $(getLastExportMaster) + 1))
   exportDirName="dadosV_${nextExport}_$instance"

   ###### Remover acesso ao moodle #######

   createControlRecord $nextExport E $2 && stopDBMaster
   ###cria arquivos de exportação na pasta Export/Fila
   copyExportFiles $exportDirName

   ###realiza a sincronização para limpar a fila de operações de sincronização pendentes
   echo "-> Limpando fila de sincronização..."
   clearQueue
   echo " ----> ...fila limpa."

   ###gera arquivo de exportação
   createExportFile "$archiveExportPath/$exportDirName.tar.gz"
   ## É PRECISO SALVAR OS ARQUIVOS EXPORTADOS EM UM REPOSITÓRIO DO MOODLE

   clearExportDir

   if [ "$option" = "3" ]; then
      echo "====> ENVIANDO ARQUIVO PARA SERVIDOR REMOTO $remoteServerAddress...."
      ret=$(copyFileToRemoteRepo $dirViewPath/$exportDirName.tar.gz)
      if [ $ret -eq 0 ]; then
         echo "........... ARQUIVO ENVIADO."
      else
         errorStatus=1
         echo "........... ERRO AO ENVIAR ARQUIVO.";
      fi
   fi

   echo " ================= PROCESSO DE EXPORTAÇÃO CONCLUÍDO. ================="

   if [ $errorStatus -eq 0 ]; then
      echo "$exportDirName.tar.gz" > $dirViewPath/syncFinalizada #sinaliza ao PHP que a sincronização foi finalizada
   else
      echo "-1" > $dirViewPath/syncFinalizada #sinaliza ao PHP que a sincronização foi finalizada
   fi
elif [ "$option" = "2" ]; then
  echo " ================= INICIANDO PROCESSO DE IMPORTAÇÃO =================\n"

  tarImport="$dirViewPath/dadosImportTemp.tar.gz"
  if [ ! -z $3 ]; then
     tarImport=$3
  fi

  tar -xpzf $tarImport -C "$dirPath/scripts/sync/Import/" #descompacta arquivo de importação para dentro de Import

  nameImportTarList=$(ls $dirPath/scripts/sync/Import/ | grep .tar.gz) #vai ter apenas um diretório pois a fila foi eliminada

  for nameTar in $nameImportTarList; do
     importNumber=$(cut -d'_' -f2 <<< "$nameTar")
     nameImportDir=$(echo $nameTar | cut -d"." -f1)
     nextImport=$(( $(getLastImportMaster) + 1))
     if [ "$importNumber" -lt  "$nextImport" ]; then ## se este diretório já foi importado - skip
        echo "== Import número $importNumber já foi realizado, o próximo sync é o de número $nextImport. Os dados não serão carregados novamente. =="
        clearImportDir $nameImportDir
     else

        if [ $errorStatus -eq 0 ]; then
           tar -xpzf $dirPath/scripts/sync/Import/$nameTar -C "$dirImportPath/"

           ### SUBSTITUIR DB_SYNC DIRECTORY
           changeDBSync $nameImportDir

           ### Fazer a sincronização de arquivos usando rsync entre a pasta de dentro do import e a pasta de arquivos do moodle
           echo " ---> SINCRONIZANDO ARQUIVOS..."
           while [ ! -e $dirImportPath/$nameImportDir/arquivos/filedir ]; do
  	          echo " ---------> ...aguardando a cópia do filedir...";
              sleep 3;
           done
	         cp -r  "$dirImportPath"/"$nameImportDir"/arquivos/filedir/* $fileDirPath/
           createFileDirList "$dirImportPath"/"$nameImportDir"/arquivos/filedir $syncFileDirListPath #create the 'fake' files coming from the importDir into the syncFileDirListPath
           echo " ---> ...ARQUIVOS SINCRONIZADOS."

           startSync #inicia a sincronização do banco de dados e espera que ela acabe

           #bdrResumeMasterSync # initially this is not needed because the sync is unpaused when the db service is restarted

           if [ $(findControlRecord $complement $importNumber E) -eq 1 ]; then
              createControlRecord $importNumber I $username
              echo "REGISTRO DE CONTROLE ENCONTRADO NA BASE PRINCIPAL - IMPORTAÇÃO REALIZADA COM SUCESSO!"
           else
              errorStatus=1
           fi
        fi
        clearImportDir $nameImportDir
	      execdockerCommand $containerMoodleName "php /app/public/admin/cli/purge_caches.php"
        restartMoodle #reinicia o moodle
     fi
  done

  echo " ================= PROCESSO DE IMPORTAÇÃO CONCLUÍDO. ================="

  if [ $errorStatus -eq 0 ]; then
     echo 1 > $dirViewPath/syncFinalizada #Sinaliza ao PHP que a sincronização foi finalizada com sucesso
  else
     echo "-1" > $dirViewPath/syncFinalizada #Sinaliza ao PHP que a sincronização foi finalizada com falha
  fi
fi

echo "Script ended!"
