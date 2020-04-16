#!/usr/bin/env bash

log info "Compilando moodle.avapolos" 

#Download do moodle 3.7
tmp=$(mktemp -d -t moodle_download.XXXXXXX)
wget -O $tmp/moodle.tgz https://download.moodle.org/stable37/moodle-latest-37.tgz
cd $MOODLE_DATA_DIR/moodle
tar xfz $tmp/moodle.tgz
rm -rf $tmp
mv moodle public
mkdir moodledata
cp -rf $MOODLE_RESOURCES_DIR/moodle/* $MOODLE_DATA_DIR/moodle/public/
envsubst '$DB_MOODLE_MOODLE_PASSWORD' < $MOODLE_DATA_DIR/moodle/public/config.php.dist > $MOODLE_DATA_DIR/moodle/public/config.php
envsubst '$DB_MOODLE_MOODLE_PASSWORD' < $MOODLE_DATA_DIR/moodle/public/avapolos_dev/impar.php.dist > $MOODLE_DATA_DIR/moodle/public/avapolos_dev/impar.php
envsubst '$DB_MOODLE_MOODLE_PASSWORD' < $MOODLE_DATA_DIR/moodle/public/avapolos_dev/par.php.dist > $MOODLE_DATA_DIR/moodle/public/avapolos_dev/par.php

cd $MOODLE_DIR
docker-compose up -d moodle

execDockerCommand "moodle" "php /app/public/admin/cli/install_database.php --lang=pt_br --adminuser=admin --adminpass=$MOODLE_ADMIN_PASSWORD --adminemail=admin@avapolos.com --fullname='Moodle AVAPolos' --shortname='Mdl AVA' --agree-license"
execDockerCommand "moodle" "php /app/public/admin/cli/upgrade.php --non-interactive"

mkdir -p $MOODLE_DATA_DIR/moodle/moodledata/repository/avapolos
execDockerCommand "moodle" "php /app/public/avapolos_dev/repo.php"

execDockerCommand "moodle" "php /app/public/avapolos_dev/impar.php"
execDockerCommand "moodle" "php /app/public/avapolos_dev/par.php"

execSqlOnMoodleDB db_moodle_ies "
  ALTER DATABASE moodle SET bdr.skip_ddl_locking = true;
  ALTER DATABASE moodle SET bdr.skip_ddl_replication = true;
"
execSqlOnMoodleDB db_moodle_polo "
  ALTER DATABASE moodle SET bdr.skip_ddl_locking = true;
  ALTER DATABASE moodle SET bdr.skip_ddl_replication = true;
"

#Email change confirmation disable.
#execSqlOnMoodleDB db_moodle_ies "UPDATE mdl_config SET VALUE=0 WHERE id=243;"

#Mobile app enable.
# execSqlOnMoodleDB db_moodle_ies "UPDATE mdl_config SET VALUE=1 WHERE id=484;"
# execSqlOnMoodleDB db_moodle_ies "UPDATE mdl_external_services SET enabled=1 WHERE shortname LIKE '%moodle_mobile_app%';"

# execSqlOnMoodleDB db_moodle_ies "SELECT * FROM mdl_config WHERE id=243 OR id=484;"
# execSqlOnMoodleDB db_moodle_ies "SELECT * FROM mdl_external_services WHERE shortname LIKE '%mobile%';"

execDockerCommand "moodle" "php /app/public/admin/cli/purge_caches.php"

echo "Checando instalação do Moodle na IES."
execSqlOnMoodleDB db_moodle_ies "SELECT * from mdl_user;"

echo "Checando instalação do Moodle no POLO."
execSqlOnMoodleDB db_moodle_polo "SELECT * from mdl_user;"

testURL "http://moodle.avapolos"
