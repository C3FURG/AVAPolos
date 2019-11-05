#!/bin/sh

while [ ! -f done ]; do
	var=$(cat wget-log | sed -sn 6p | awk '{print $1 $3}')
	sleep 5
	if [ "$var" = "$oldVar" ]; then
		echo $var
	fi
	oldVar=$var
done

var="done"

echo $var

