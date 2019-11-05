#!/bin/bash

cd /opt/

if [ -f backups/latest.log ]; then
	rm backups/latest.log
fi

while [ 1 ]; do
	if [ -f backups/latest.log ]; then
	rm backups/latest.log
	fi
	bash backup.sh
	sleep 3m
done
