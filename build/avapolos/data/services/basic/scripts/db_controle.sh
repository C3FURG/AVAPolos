#!/usr/bin/env bash

echo "Assegurando permissões corretas." | log debug data_compiler
sudo chown -R $USER:$USER .

cd $BASIC_DIR

echo "Iniciando db_moodle_ies e db_moodle_polo" | log debug data_compiler
docker-compose up -d db_controle

waitForHealthy db_controle

execSqlOnMoodleDB db_controle "CREATE DATABASE avapolos;"

execSQL db_controle avapolos "
  CREATE ROLE avapolos;
  ALTER USER avapolos WITH LOGIN PASSWORD '@bancoava.C4p35*&';
  GRANT ALL PRIVILEGES ON DATABASE avapolos TO avapolos;
";

execSQL db_controle avapolos "
CREATE TABLE public.controle_login
(
    id SERIAL PRIMARY KEY,
    login character varying(255) NOT NULL,
    password character varying(255) NOT NULL
);
ALTER TABLE public.controle_login OWNER to avapolos;
"

hash=$(echo -n $CONTROLE_PASSWORD | md5sum | cut -d ' ' -f 1)
execSQL db_controle avapolos "
  INSERT INTO controle_login (login, password) VALUES ('admin', '$hash');
"

if ! [[ -z "$(execSQL db_controle avapolos "SELECT * FROM controle_login;" | grep -o row)" ]]; then
  echo "Banco configurado com sucesso." | log debug data_compiler
else
  echo "Ocorreu um erro na configuração do banco, parando script." | log error data_compiler
  exit 1
fi
