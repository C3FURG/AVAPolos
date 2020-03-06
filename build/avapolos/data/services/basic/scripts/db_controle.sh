#!/usr/bin/env bash

echo "Assegurando permissões corretas." | log debug data_compiler
sudo chown -R $USER:$USER .

cd $BASIC_DIR

echo "Iniciando db_moodle_ies e db_moodle_polo" | log debug data_compiler
docker-compose up -d db_controle

waitForHealthy db_controle

execSQL db_controle avapolos avapolos "
  ALTER USER avapolos WITH PASSWORD 'bd10b9a2e191deafe6af';
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
      email_dev character varying(255) NOT NULL,
  );
"

hash=$(echo -n $CONTROLE_PASSWORD | md5sum | cut -d ' ' -f 1)
execSQL db_controle avapolos avapolos "
INSERT INTO public.controle_login (login, password) VALUES ('admin', '$hash');
"

execSQL db_controle avapolos avapolos "
  SELECT * FROM public.controle_login;
"

if ! [[ -z "$(execSQL db_controle avapolos avapolos "SELECT * FROM public.controle_login;" | grep -o row)" ]]; then
  echo "Banco configurado com sucesso." | log debug data_compiler
else
  echo "Ocorreu um erro na configuração do banco, parando script." | log error data_compiler
  exit 1
fi
