#!/usr/bin/env bash

fix() {
  sed -i -E "s/\| log debug$/\| log debug "$1"/g" $2;
  sed -i -E "s/\| log info$/\| log info "$1"/g" $2;
  sed -i -E "s/\| log warn$/\| log warn "$1"/g" $2;
  sed -i -E "s/\| log error$/\| log error "$1"/g" $2;
}

for file in $(find build/avapolos/scripts/install -name "*.sh"); do
  fix "installer" $file
done
