#!/usr/bin/env bash

cd $MOODLE_DIR

echo "Assegurando permissões corretas." | log debug data_compiler
sudo chown -R $USER:$USER .

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
execSQL db_moodle_ies "
  CREATE ROLE bdrsync superuser;
  ALTER USER bdrsync WITH LOGIN PASSWORD '@bancoava.C4p35*&';
  CREATE USER moodleuser WITH LOGIN PASSWORD '@bancoava.C4p35*&';
  GRANT ALL PRIVILEGES ON DATABASE moodle TO moodleuser;
  CREATE EXTENSION btree_gist;
  CREATE EXTENSION bdr;
";

echo "Criando grupo de replicação BDR." | log debug data_compiler
execSQL db_moodle_ies "
  SELECT bdr.bdr_group_create(
    local_node_name := 'IES',
    node_external_dsn := 'host=db_moodle_ies user=bdrsync dbname=moodle password=@bancoava.C4p35*&'
  );
";
execSQL db_moodle_ies "SELECT bdr.bdr_node_join_wait_for_ready()";
execSQL db_moodle_ies "SELECT bdr.bdr_nodes.node_status FROM bdr.bdr_nodes;";

echo "Criando base de dados, configurando usuários e habilitando o BDR na db_moodle_polo" | log debug data_compiler
execSQL db_moodle_polo "
  CREATE ROLE bdrsync superuser;
  ALTER USER bdrsync WITH LOGIN PASSWORD '@bancoava.C4p35*&';
  CREATE USER moodleuser WITH LOGIN PASSWORD '@bancoava.C4p35*&';
  GRANT ALL PRIVILEGES ON DATABASE moodle TO moodleuser;
  CREATE EXTENSION btree_gist;
  CREATE EXTENSION bdr;
";
echo "Entrando no grupo de replicação BDR." | log debug data_compiler
execSQL db_moodle_polo "
  SELECT bdr.bdr_group_join(
    local_node_name := 'POLO',
    node_external_dsn := 'host=db_moodle_polo user=bdrsync dbname=moodle password=@bancoava.C4p35*&',
    join_using_dsn := 'host=db_moodle_ies user=bdrsync dbname=moodle password=@bancoava.C4p35*&'
  );
";
execSQL db_moodle_ies "SELECT bdr.bdr_nodes.node_status FROM bdr.bdr_nodes;";
sleep 3
execSQL db_moodle_polo "SELECT bdr.bdr_node_join_wait_for_ready()";
execSQL db_moodle_ies "SELECT bdr.bdr_nodes.node_status FROM bdr.bdr_nodes;";

#DEFAULT
echo "Criando tabela avapolos_sync na IES." | log debug data_compiler
execSQLMoodle db_moodle_ies "
  CREATE TABLE avapolos_sync (
    id serial not null PRIMARY KEY,
    instancia char(4) not null,
    versao int not null,
    tipo char(1) not null,
    data timestamptz not null DEFAULT NOW(),
    moodle_user varchar(255) not null
  );
";

execSQL db_moodle_ies "SELECT bdr.bdr_nodes.node_status FROM bdr.bdr_nodes;";
echo "Checando se a tabela foi replicada para o POLO." | log debug data_compiler
execSQL db_moodle_polo "SELECT bdr.wait_slot_confirm_lsn(NULL, NULL)";
execSQL db_moodle_ies "SELECT bdr.wait_slot_confirm_lsn(NULL, NULL)";

if ! [[ -z "$(execSQL db_moodle_polo "SELECT * FROM avapolos_sync;" | grep -o row)" ]]; then
  echo "Replicação BDR configurada com sucesso." | log debug data_compiler
else
  echo "Ocorreu um erro na replicação BDR, parando script." | log error data_compiler
  exit 1
fi
