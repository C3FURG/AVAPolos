#!/usr/bin/env bash
#https://unix.stackexchange.com/questions/86722/how-do-i-loop-through-only-directories-in-bash
{

	echo " "
	echo "----------------"
	echo "Backup AVA-Polos"
	echo "------ ---------"

	DATE=$(date +%F)
	FILENAME="backup_$DATE.tgz"

	echo "DIA: $DATE"
	echo " "

	FIND=$(find ./backups -mtime +2 -type f)

	echo "Arqvivos antigos: $FIND"

	find ./backups -mtime +2 -type f -delete

	cd backups

	mkdir temp

	cd /volumes/

	for f in *; do
    	if [ -d ${f} ]; then
        # Will not run if no directories are available
        cp -r $f /opt/backups/temp
        echo "Backup do volume $f"
    	fi
	done

	cd /opt/backups/temp

	echo "Compactando."
	tar cfz $FILENAME *

	mv $FILENAME ..

	cd ..

	echo "Excluindo diretório temporário"
	
	rm -r temp

	if [ -f $FILENAME ]; then
		echo "Arquivo de backup $FILENAME criado com sucesso."
	else
		echo "Arquivo de backup não foi criado, erro no backup."
	fi

} | tee backups/latest.log 


