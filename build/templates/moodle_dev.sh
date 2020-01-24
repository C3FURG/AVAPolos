#!/usr/bin/env bash

unset description
unset images
unset stacks

description="Pacote para desenvolvimento do Moodle AVA-Polos
Página inicial (inicio.avapolos)
Painel de controle (controle.avapolos)
Portainer (portainer.avapolos)
Moodle (moodle.avapolos)"

images="avapolos/webserver:lite
avapolos/dnsmasq:latest
library/traefik:v1.7
portainer/portainer
avapolos/dyndns
avapolos/postgres:bdr
"

stacks="basic.yml
moodle.yml"
