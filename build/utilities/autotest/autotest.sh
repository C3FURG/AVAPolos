#!/usr/bin/env bash

echo "Iniciando serviço de testes AVA-Polos"

flag="false"
if ! [[ -f "/opt/downloaded" ]]; then
  while [[ $flag = "false" ]] ; do
    sleep 2
    ping -c 1 10.230.0.45
    if [[ $? -eq 0 ]] ; then
      flag="true"
    fi
  done
  echo "Rodando baixar_instalador.sh"
  bash /opt/baixar_instalador.sh
  touch /opt/downloaded
else
  echo "Esta máquina já baixou o instalador automaticamente."
fi
