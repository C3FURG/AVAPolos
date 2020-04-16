#!/usr/bin/env bash

log info "Compilando db_controle" 

log debug "Iniciando db_controle" 
docker-compose up -d db_controle

waitForHealthy db_controle

execSQL db_controle postgres postgres "
  CREATE DATABASE avapolos;
"
execSQL db_controle postgres postgres "
  CREATE ROLE avapolos WITH LOGIN PASSWORD '$DB_CONTROLE_AVAPOLOS_PASSWORD';
  GRANT ALL ON DATABASE avapolos TO avapolos;
"
execSQL db_controle avapolos avapolos "
  CREATE TABLE public.controle_login
  (
      id SERIAL PRIMARY KEY,
      login character varying(255) NOT NULL,
      password character varying(255) NOT NULL,
      last_login timestamp
  );
"
#Text é infinito, pensar melhor.
execSQL db_controle avapolos avapolos "
  CREATE TABLE public.controle_reporte
  (
      id SERIAL PRIMARY KEY,
      nome character varying(255) NOT NULL,
      local character varying(255) NOT NULL,
      data timestamp NOT NULL,
      comentario text
  );
"

execSQL db_controle avapolos avapolos "
  CREATE TABLE public.controle_registro
  (
      id SERIAL PRIMARY KEY,
      email_dev character varying(255) NOT NULL
  );
"

execSQL db_controle avapolos avapolos "
INSERT INTO public.controle_login (login, password) VALUES ('admin', '$CONTROLE_ADMIN_PASSWORD_HASH');
"

execSQL db_controle avapolos avapolos "
  SELECT * FROM public.controle_login;
"

if ! [[ -z "$(execSQL db_controle avapolos avapolos "SELECT * FROM public.controle_login;" | grep -o row)" ]]; then
  log debug "Banco configurado com sucesso." 
else
  log error "Ocorreu um erro na configuração do banco, parando script." 
  exit 1
fi
