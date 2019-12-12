#!/usr/bin/env bash

#Check if it's already installed.
#If yes, ask to rewrite it.
#If not, continue.
if [ -f "/etc/avapolos/header.sh" ]; then
  source /etc/avapolos/header.sh
elif [ -f "header.sh" ]; then
  source header.sh
else
  echo "ERRO: Não foi encontrado o arquivo header.sh"
  echo "PWD: $PWD"
fi

if [ -f "/etc/avapolos/header.sh" ]; then
  echo "Uma instalação existente foi detectada"
  input "Deseja sobrescrevê-la?" "sim" "nao" 0 "Você precisa selecionar uma opção!"
  if [ "$option" = "nao" ]; then
    echo "Cancelando instalação."
    exit 1
  else
    sudo avapolos --uninstall
    if [ $? -ne 0 ]; then
      echo "A instalação não teve sucesso."
      input "Deseja remover na força bruta?" "sim" "nao" 0 "Você precisa selecionar uma opção!"
      if [ "$option" = "nao" ]; then
        echo "Cancelando desinstalação."
        exit
      else
        sudo rm -rf $ROOT_PATH
        sudo rm -rf $LOG_PATH
        sudo rm -rf $ETC_PATH
      fi
    fi
  fi
fi

#Show the solution's license.
showLicense

#Check for exec arguments.
#If -y is present, don't ask the user to proceed with the installation.
#If it's not, ask the user.
if ! [ "$1" = "-y" ]; then
  input "Deseja instalar a solução AVAPolos?" "sim" "nao" 0 "Você precisa selecionar uma opção!"
  if [ "$option" = "nao" ]; then
    echo "Cancelando instalação."
    exit
  fi
fi

if [ -d "/usr/share/applications" ]; then
  #Make a .desktop shortcut to the webpanel.
  cp avapolos.desktop /usr/share/applications
  chmod 644 /usr/share/applications/avapolos.desktop
fi

#Create the user and the group.
echo "Criando usuário $AVAPOLOS_USER."
echo "Criando grupo $AVAPOLOS_GROUP."
groupadd -f $AVAPOLOS_GROUP
useradd -s /bin/bash -c "Usuário da solução AVAPolos" -m -N -g $AVAPOLOS_GROUP -G sudo $AVAPOLOS_USER || true
#FIXME: Não posso parar de usar senha por causa do php da sync!!!!
echo -e "avapolos\navapolos" | sudo passwd $AVAPOLOS_USER

#Install the necessary header and setup the permissions.
#TODO: segurança.
mkdir -p $ETC_PATH
mkdir -p $LOG_PATH
mkdir -p $SERVICE_PATH

cp avapolos.sh $ETC_PATH
cp header.sh $ETC_PATH
cp version $ETC_PATH
cp service_daemon.sh $SERVICE_PATH
touch $LOG_PATH/avapolos.log

chmod +x $ETC_PATH/header.sh
chmod +x $ETC_PATH/avapolos.sh

chown $PUID:$PGID $ETC_PATH -R
chown $PUID:$PGID $LOG_PATH -R

#Make a symlink so the cli can be accessed without full path.
ln -sf $ETC_PATH/avapolos.sh /usr/local/bin/avapolos

#Read the header.
source $ETC_PATH/header.sh

#Run the install script.
avapolos --install
