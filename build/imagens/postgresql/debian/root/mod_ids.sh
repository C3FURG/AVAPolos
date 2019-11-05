#!/usr/bin/env bash

set -e

if ! [ -z "$PUID" ] && ! [ -z "$PGID" ]; then
    usermod -u $PUID postgres
    groupmod -g $PGID postgres
    echo "UID modificado: $PUID"
    echo "GID modificado: $PGID"
fi
