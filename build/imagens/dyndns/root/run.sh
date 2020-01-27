#!/bin/sh

noipy -u $USER -p $PASS -n $DOMAIN --provider noip $(curl https://canihazip.com/s)
