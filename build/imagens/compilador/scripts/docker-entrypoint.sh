#!/usr/bin/env bash

#echo "Cmandos: $@"

if ! [[ -z "$PUID" ]]; then
  usermod -u $PGID avapolos
  #echo "UID moficado: $(id -u avapolos)"
fi

if ! [[ -z "$PGID" ]]; then
  groupmod -g $PGID avapolos
  #echo "GID moficado: $(id -g avapolos)"
fi

chown $PUID:$PGID /home/avapolos -R

sudo -H -u avapolos $@
