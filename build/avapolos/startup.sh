#!/usr/bin/env bash

if [ -d "/opt/avapolos" ]; then
  echo "Uma instalação existente foi detectada no diretório /opt/avapolos."
  echo "Desinstale-a utilizando o comando 'sudo avapolos --uninstall'."
  echo "ATENÇÃO: Certifique-se de salvar os dados dos serviços AVAPolos."
  exit 1
fi

mkdir -p /opt/avapolos

cp AVAPolos.tar.gz /opt/avapolos

if ! [[ $? -eq 0 ]]; then
  echo "ERRO: Não foi possível copiar o arquivo AVAPolos.tar.gz!"
  exit 1
fi

echo "Extraindo o arquivo compactado."
cd /opt/avapolos && tar xfzv AVAPolos.tar.gz

source header.sh

#Show the solution's license.
showLicense

#Create the user and the group.
echo "Criando usuário $AVAPOLOS_USER."
echo "Criando grupo $AVAPOLOS_GROUP."
groupadd -f $AVAPOLOS_GROUP
useradd -s /bin/bash -c "Usuário da solução AVAPolos" -m -N -g $AVAPOLOS_GROUP -G sudo $AVAPOLOS_USER || true

#FIXME: Não posso parar de usar senha por causa do php da sync!!!!
echo -e "avapolos\navapolos" | sudo passwd $AVAPOLOS_USER

#Ensure install directory permissions.
chown $(id -u avapolos):$(id -g avapolos) -R /opt/avapolos

#Make a symlink so the cli can be accessed without full path.
ln -sf /opt/avapolos/avapolos.sh /usr/local/bin/avapolos

#Run the install script.
avapolos --install
