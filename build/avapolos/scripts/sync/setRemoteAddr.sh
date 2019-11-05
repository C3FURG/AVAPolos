#!/bin/bash
#$1 = ip or domain name
ret=$(ping -4 -c 1 $1)
if [ $? -ne 0 ]; then
   echo -1;
else
   ip=$(echo "$ret" | head -n1 | grep -Eo -m1 "([0-9]{1,3}\.){3}([0-9]{1,3})" | head -n1)
   remoteAddr=$(cat variables.sh | grep remoteServerAddress | grep -o \".*\" | sed -e "s/\"//g");
   #echo "Substitui esse ip $remoteAddr por esse $ip no variables.sh"
   sed -i -e "s/remoteServerAddress=\"$remoteAddr\"/remoteServerAddress=\"$ip\"/g" variables.sh
   echo 1;
fi
