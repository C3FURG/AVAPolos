#!/usr/bin/env bash

log debug "Compilando wiki.avapolos" 

tmp=$(mktemp -d -t wiki_download.XXXXXXX)
wget -O $tmp/wiki.tar.gz https://releases.wikimedia.org/mediawiki/1.31/mediawiki-1.31.4.tar.gz
cd $WIKI_DATA_DIR/wiki
tar xfz $tmp/wiki.tar.gz
mv mediawiki* public
cd public
cp -rf $WIKI_RESOURCES_DIR/* .

cd $WIKI_DIR
docker-compose up -d wiki

docker exec -it wiki php /app/public/maintenance/install.php --dbtype="postgres" \
  --dbserver="db_wiki" \
  --dbuser='wiki' \
  --dbname='wiki' \
  --dbpass="$DB_WIKI_WIKI_PASSWORD" \
  --server='http://wiki.avapolos' \
  --scriptpath='http://wiki.avapolos' \
  --lang=pt-br \
  --pass="$WIKI_PASSWORD" \
  "Wiki AVAPolos" \
  "Admin"

testURL "http://wiki.avapolos"
