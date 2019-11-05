#!/usr/bin/env bash

#AVA-Polos
#install.sh
#This is the main script ran by the installation procedure.
#It calls all the other scripts to perform various functions in order to install the solution.

#This script needs to run as root.
if [ "$EUID" -ne 0 ]; then
  echo "Este script precisa ser rodado como root" | log error
  exit
fi

#If the header file is present on the system.
if [ -f "/etc/avapolos/header.sh" ]; then
  #Source it.
  source /etc/avapolos/header.sh
#If it's not present.
else
  #Tell the user and exit with an error code.
  echo "Não foi encontrado o arquivo header.sh" | log error
  exit 1
fi

export LOGGER_LVL="debug"

#Go to the install scripts path.
cd $INSTALL_SCRIPTS_PATH

#Declare the execution order for the install scripts.
scripts=( "checks.sh" "install_dependencies.sh" "install_images.sh" "install_networking.sh" "install_services.sh" "cleanup.sh" )
#Declare how many install scripts we need to run.
scriptsLen=${#scripts[@]}
#A counter for the progress bar.
counter=0

#For every script in the list
for s in "${scripts[@]}"; do

	#Execute the next script in the list with admin privileges.
	#And pass any argument passed to the main install script to it.
	bash $s $@

	#If the last script's return code wasn't 0
	if [ $? -ne 0 ]; then
		#Tell the user that's an error and exit the script.
		echo "Erro no script $s" | log error
		exit 1
	#If it was 0
	else
		#Print the progress.
		counter=$(($counter + 1))
		echo "-------------------------------"                 | log info
		echo "Progresso da instalação: ($counter/$scriptsLen)" | log info
		echo "-------------------------------"                 | log info
	fi

done

#Start the solution's execution
start

#Start the solution's main service
echo "Iniciando serviço principal." | log debug
systemctl start avapolos.service | log debug
