#!/usr/bin/env bash

cd $MOODLE_DIR
sudo chown -R $USER:$USER .

tmp=$(mktemp -d -t moodle_download.XXXXXXX)
wget -O $tmp/moodle.tgz https://download.moodle.org/stable37/moodle-latest-37.tgz
sudo rm -rf $MOODLE_DATA_DIR/moodle/*

cd $MOODLE_DATA_DIR/moodle
tar xfz $tmp/moodle.tgz
mv moodle public
mkdir moodledata

echo "Iniciando webserver"
docker-compose up -d moodle

echo "Instalando moodle na IES."
echo "Senha: $MOODLE_PASSWORD"
#cp -rf $MOODLE_RESOURCES_DIR/moodle/config.php $MOODLE_DATA_DIR/moodle/public/
cp -rf $MOODLE_RESOURCES_DIR/moodle/* $MOODLE_DATA_DIR/moodle/public/
execDockerCommand "moodle" "php /app/public/admin/cli/install_database.php --lang=pt_br --adminuser=admin --adminpass=$MOODLE_PASSWORD --adminemail=admin@avapolos.com --fullname='Moodle AVAPolos' --shortname='Mdl AVA' --agree-license"

execDockerCommand moodle "php /app/public/admin/cli/upgrade.php --non-interactive"
execDockerCommand moodle "php /app/public/avapolos_dev/impar.php"
execDockerCommand moodle "php /app/public/avapolos_dev/par.php"

execSQL db_moodle_ies "
  ALTER DATABASE moodle SET bdr.skip_ddl_locking = true;
  ALTER DATABASE moodle SET bdr.skip_ddl_replication = true;
"
execSQL db_moodle_polo "
  ALTER DATABASE moodle SET bdr.skip_ddl_locking = true;
  ALTER DATABASE moodle SET bdr.skip_ddl_replication = true;
"

#Email change confirmation disable.
#execSQL db_moodle_ies "UPDATE mdl_config SET VALUE=0 WHERE id=243;"

#Mobile app enable.
# execSQL db_moodle_ies "UPDATE mdl_config SET VALUE=1 WHERE id=484;"
# execSQL db_moodle_ies "UPDATE mdl_external_services SET enabled=1 WHERE shortname LIKE '%moodle_mobile_app%';"

# execSQL db_moodle_ies "SELECT * FROM mdl_config WHERE id=243 OR id=484;"
# execSQL db_moodle_ies "SELECT * FROM mdl_external_services WHERE shortname LIKE '%mobile%';"

execDockerCommand "moodle" "php /app/public/admin/cli/purge_caches.php"

echo "Checando instalação do Moodle na IES."
execSQL db_moodle_ies "SELECT * from mdl_user;"

echo "Checando instalação do Moodle no POLO."
execSQL db_moodle_polo "SELECT * from mdl_user;"

testURL "http://moodle.avapolos"

rm -rf $tmp
