#!/usr/bin/env bash

cd $WIKI_DIR

tmp=$(mktemp -d -t wiki_download.XXXXXXX)
wget -O $tmp/wiki.tar.gz https://releases.wikimedia.org/mediawiki/1.31/mediawiki-1.31.4.tar.gz

cd $WIKI_DATA_DIR/wiki
sudo rm -rf *
tar xfz $tmp/wiki.tar.gz
mv mediawiki* public
cd public

cp -rf $WIKI_RESOURCES_DIR/* .
sudo chown -R $USER:$USER $WIKI_DIR

cd $WIKI_DIR
docker-compose up -d wiki

echo "Instalando wiki."
echo "Senha: $WIKI_PASSWORD"
docker exec -it wiki php /app/public/maintenance/install.php --dbtype="postgres" \
  --dbserver="db_wiki" \
  --dbuser='wiki' \
  --dbname='wiki' \
  --dbpass='@bancoava.C4p35*&' \
  --server='http://wiki.avapolos' \
  --scriptpath='http://wiki.avapolos' \
  --lang=pt-br \
  --pass="$WIKI_PASSWORD" \
  "Wiki Name" \
  "Admin"

testURL "http://wiki.avapolos"
