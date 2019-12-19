#!/usr/bin/env bash

exit() {
  fusermount -u ../remote-ava
  rm -rf ../remote-ava
}

trap exit EXIT
trap exit SIGTERM

mkdir -p ../remote-ava
sshfs avapolos@$1:/opt/avapolos ../remote-ava
