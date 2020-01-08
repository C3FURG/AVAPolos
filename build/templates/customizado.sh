#!/usr/bin/env bash

unset description
unset images
unset stacks

description="Pacote para testes com serviços customizados.
Página inicial (inicio.avapolos)
Painel de controle (controle.avapolos)
Portainer (portainer.avapolos)
Wordpress (teste.avapolos)
"

images="avapolos/webserver:lite
avapolos/dnsmasq:latest
library/traefik:v1.7
portainer/portainer
coppit/noip
mysql:5.7
wordpress:latest
"

stacks="basic.yml
moodle_test.yml
"
