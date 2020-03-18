#!/usr/bin/env bash

echo "Compilando db_moodle_ies e db_moodle_polo" | log debug data_compiler

echo "Iniciando db_moodle_ies e db_moodle_polo" | log debug data_compiler
docker-compose up -d db_moodle_ies db_moodle_polo

waitForHealthy db_moodle_ies
waitForHealthy db_moodle_polo

echo "Parando os bancos de dados." | log debug data_compiler
docker-compose down

echo "Copiando arquivos de configuração." | log debug data_compiler
cp $MOODLE_RESOURCES_DIR/db/pg_hba.conf $MOODLE_DATA_DIR/db_moodle_ies
cp $MOODLE_RESOURCES_DIR/db/pg_hba.conf $MOODLE_DATA_DIR/db_moodle_polo

cp $MOODLE_RESOURCES_DIR/db/postgresql.conf $MOODLE_DATA_DIR/db_moodle_ies
cp $MOODLE_RESOURCES_DIR/db/postgresql.conf $MOODLE_DATA_DIR/db_moodle_polo

echo "Iniciando bancos de dados." | log debug data_compiler
docker-compose up -d db_moodle_ies db_moodle_polo

waitForHealthy db_moodle_ies
waitForHealthy db_moodle_polo

echo "Criando base de dados, configurando usuários e habilitando o BDR na db_moodle_ies." | log debug data_compiler

execSQL db_moodle_ies postgres postgres "
  CREATE DATABASE moodle;
"

execSQL db_moodle_ies postgres moodle "
  CREATE EXTENSION btree_gist;
  CREATE EXTENSION bdr;
"

execSQL db_moodle_ies postgres moodle "
  CREATE USER bdrsync superuser;
  CREATE USER moodle;
  ALTER USER bdrsync WITH LOGIN PASSWORD '$DB_MOODLE_BDRSYNC_PASSWORD';
  ALTER USER moodle WITH LOGIN PASSWORD '$DB_MOODLE_MOODLE_PASSWORD';
  ALTER DATABASE moodle OWNER TO moodle;
  GRANT ALL PRIVILEGES ON DATABASE moodle TO moodle;
"

execSQL db_moodle_ies postgres moodle "
  SELECT bdr.bdr_group_create(
    local_node_name := 'IES',
    node_external_dsn := 'host=db_moodle_ies user=bdrsync dbname=moodle password=$DB_MOODLE_BDRSYNC_PASSWORD'
  );
";

execSQL db_moodle_ies postgres moodle "SELECT bdr.bdr_node_join_wait_for_ready()";
execSQL db_moodle_ies postgres moodle "SELECT bdr.bdr_nodes.node_status FROM bdr.bdr_nodes;";

echo "Criando base de dados, configurando usuários e habilitando o BDR na db_moodle_polo." | log debug data_compiler

execSQL db_moodle_polo postgres postgres "
  CREATE DATABASE moodle;
"

execSQL db_moodle_polo postgres moodle "
  CREATE EXTENSION btree_gist;
  CREATE EXTENSION bdr;
"

execSQL db_moodle_polo postgres moodle "
  CREATE USER bdrsync superuser;
  CREATE USER moodle;
  ALTER USER bdrsync WITH LOGIN PASSWORD '$DB_MOODLE_BDRSYNC_PASSWORD';
  ALTER USER moodle WITH LOGIN PASSWORD '$DB_MOODLE_MOODLE_PASSWORD';
  ALTER DATABASE moodle OWNER TO moodle;
  GRANT ALL PRIVILEGES ON DATABASE moodle TO moodle;
"

echo "Entrando no grupo de replicação BDR." | log debug data_compiler
execSQL db_moodle_polo postgres moodle "
  SELECT bdr.bdr_group_join(
    local_node_name := 'POLO',
    node_external_dsn := 'host=db_moodle_polo user=bdrsync dbname=moodle password=$DB_MOODLE_BDRSYNC_PASSWORD',
    join_using_dsn := 'host=db_moodle_ies user=bdrsync dbname=moodle password=$DB_MOODLE_BDRSYNC_PASSWORD'
  );
";

execSQL db_moodle_polo postgres moodle "SELECT bdr.bdr_nodes.node_status FROM bdr.bdr_nodes;";
execSQL db_moodle_polo postgres moodle "SELECT bdr.bdr_node_join_wait_for_ready()";
execSQL db_moodle_ies postgres moodle "SELECT bdr.bdr_nodes.node_status FROM bdr.bdr_nodes;";

echo "Criando tabela avapolos_sync na IES." | log debug data_compiler
execSqlOnMoodleDB db_moodle_ies "
  CREATE TABLE avapolos_sync (
    id serial not null PRIMARY KEY,
    instancia char(4) not null,
    versao int not null,
    tipo char(1) not null,
    data timestamptz not null DEFAULT NOW(),
    moodle_user varchar(255) not null
  );
";

execSQL db_moodle_ies postgres moodle "SELECT bdr.bdr_nodes.node_status FROM bdr.bdr_nodes;";
echo "Checando se a tabela foi replicada para o POLO." | log debug data_compiler
execSQL db_moodle_polo postgres moodle "SELECT bdr.wait_slot_confirm_lsn(NULL, NULL)";
execSQL db_moodle_ies postgres moodle "SELECT bdr.wait_slot_confirm_lsn(NULL, NULL)";

if ! [[ -z "$(execSqlOnMoodleDB db_moodle_polo "SELECT * FROM avapolos_sync;" | grep -o row)" ]]; then
  echo "Replicação BDR configurada com sucesso." | log debug data_compiler
else
  echo "Ocorreu um erro na replicação BDR, parando script." | log error data_compiler
  exit 1
fi
