#!/usr/bin/env bash

unset description
unset images
unset stacks

description="Pacote de serviços completo.
Página inicial (inicio.avapolos)
Painel de controle (controle.avapolos)
Portainer (portainer.avapolos)
Moodle (moodle.avapolos)
Wiki (wiki.avapolos)
eduCAPES (educapes.avapolos)"

images="avapolos/postgres:bdr
avapolos/webserver:lite
avapolos/dnsmasq:latest
library/traefik:v1.7
coppit/no-ip
avapolos/backup:stable
portainer/portainer
avapolos/dspace:latest
avapolos/dspacedb:latest
"

stacks="basic.yml
moodle.yml
wiki.yml
educapes.yml"
