#!/usr/bin/env bash

cd $BASIC_DIR
sudo chown -R $USER:$USER .
sudo rm -rf $BASIC_DATA_DIR/downloads/*
mkdir -p $BASIC_DATA_DIR/downloads/public

cp -rf $BASIC_RESOURCES_DIR/downloads/public $BASIC_DATA_DIR/downloads/
mkdir -p $BASIC_DATA_DIR/downloads/public/fontawesome

tmp=$(mktemp -d -t downloads_vendor_download.XXXXXXX)
wget -O $tmp/fontawesome.zip https://use.fontawesome.com/releases/v5.11.2/fontawesome-free-5.11.2-web.zip
cd $tmp
unzip fontawesome.zip
cd $BASIC_DIR
cp -rf $tmp/fontawesome-free-5.11.2-web/* $BASIC_DATA_DIR/downloads/public/fontawesome

wget -O $BASIC_DATA_DIR/downloads/public/instaladores/moodledesktoplinux32.tgz https://download.moodle.org/desktop/download.php?platform=linux'&'arch=32
wget -O $BASIC_DATA_DIR/downloads/public/instaladores/moodledesktoplinux64.tgz https://download.moodle.org/desktop/download.php?platform=linux'&'arch=64
wget -O $BASIC_DATA_DIR/downloads/public/instaladores/moodledesktopwindows.zip https://download.moodle.org/desktop/download.php?platform=windows
wget -O $BASIC_DATA_DIR/downloads/public/instaladores/moodlemobile.apk https://download.moodle.org/desktop/download.php?platform=android

echo "Iniciando webserver"

docker-compose up -d downloads

testURL "http://downloads.avapolos"
testURL "http://downloads.avapolos/instaladores/moodledesktoplinux32.tgz"
testURL "http://downloads.avapolos/instaladores/moodledesktoplinux64.tgz"
testURL "http://downloads.avapolos/instaladores/moodledesktopwindows.zip"
testURL "http://downloads.avapolos/instaladores/moodlemobile.apk"

rm -rf $tmp
