#!/usr/bin/env bash

unset description
unset images
unset stacks

description="Pacote mínimo de serviços.
Página inicial (inicio.avapolos)
Painel de controle (controle.avapolos)
Portainer (portainer.avapolos)"

images="avapolos/webserver:lite
avapolos/dnsmasq:latest
library/traefik:v1.7
romeupalos/noip
portainer/portainer
"

stacks="basic.yml"
