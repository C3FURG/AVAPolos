#!/usr/bin/env bash

unset description
unset images
unset stacks

description="Pacote de serviços completo. (Sem eduCAPES)
Página inicial (inicio.avapolos)
Painel de controle (controle.avapolos)
Portainer (portainer.avapolos)
Moodle (moodle.avapolos)
Wiki (wiki.avapolos)
"

images="avapolos/postgres:bdr
avapolos/webserver:lite
avapolos/dnsmasq:latest
library/traefik:v1.7
avapolos/backup:stable
portainer/portainer
coppit/no-ip
"

stacks="basic.yml
moodle.yml
wiki.yml
"
