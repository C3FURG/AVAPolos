#!/usr/bin/env bash

unset description
unset images
unset stacks

description="Pacote para testes com o Moodle atualizado e limpo.
Página inicial (inicio.avapolos)
Painel de controle (controle.avapolos)
Portainer (portainer.avapolos)
Moodle Teste (moodletest.avapolos)"

images="avapolos/webserver:lite
avapolos/dnsmasq:latest
library/traefik:v1.7
portainer/portainer
romeupalos/noip
avapolos/postgres:bdr
"

stacks="basic.yml
moodle_test.yml"
