#!/bin/bash

echo "
+--------------------------------+
| Backup da instalação AVA-Polos |
+--------------------------------+
"

echo "Este script selecionará o arquivo AVAPolos_instalador_IES.tar.gz e fará uma cópia de segurança de acordo com a data do dia."
echo " "
#Em desenvolvimento.
#echo "Para seleção de qual backup restaurar, execute o script 'restore.sh'."

#Seleção da data e do nome do arquivo a ser copiado.
date=$(date +%d-%m-%Y)
filename="AVAPolos_instalador_IES"

#bash build.sh

#Digitando um comentário para melhor organização para os testes.
echo "

Digite um comentário sobre este backup: 
"
read commentary

cd ../backups

#Se não encontarar uma pasta com a data do dia, criar uma e copiar o primeiro backup do dia para dentro dela.
#Em seguida, adicionar o comentário desse backup na pasta em questão. 
if ! [ -d "$date" ]; then
    mkdir $date
    cp ../$filename.tar.gz $date
    echo -e "$filename -> $commentary \r"                   >> $date/comentarios.txt
    echo -e "---------------------------------------------" >> $date/comentarios.txt
else
    #Se encontrar uma pasta com a data do dia atual, mudar o nome do arquivo para evitar conflitos.
    #Isso possibilita inúmeros backups por dia.
    if [[ -e $date/$filename.tar.gz ]] ; then
        i=2
        while [[ -e $date/$filename-$i.tar.gz ]] ; do
            let i++
        done
        filename2=$filename-$i.tar.gz
    fi
    cp ../$filename.tar.gz $date/$filename2
    echo -e "$filename2 -> $commentary \r"                   >> $date/comentarios.txt
    echo -e "---------------------------------------------" >> $date/comentarios.txt
fi

echo "
+--------------------------------+
| Backup da instalação concluído |
+--------------------------------+
"
