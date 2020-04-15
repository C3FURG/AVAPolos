#!/usr/bin/env bash

files=$(find ../../../../ -name 'install_networking.sh')

for file in $files; do
  echo $file
  grep -En '((^\ +echo)|(^echo)).+\|\ log' "$file" | while read -r line ; do

    number="$(echo $line | cut -d: -f1)"
    content="$(echo $line | cut -d: -f2)"
    message="$(echo $content | sed 's/echo//' | rev | cut -d\| -f2 | rev)"
    logCmd="$(echo $content | rev | cut -d\| -f1 | rev)"
    logLevel=$(echo $logCmd | awk '{print $2}')
    newLine="log $logLevel $message"

    echo "Processing line #$number: $content"
    if [[ "$logCmd" =~ log ]]; then
      echo "  Message: $message"
      echo "  Logger command: $logCmd"
      echo "  Logger level: $logLevel"
      echo "  New Line: $newLine"
      sed -i "$number"'s/.*/'"$newLine"'/' $file
    else
      echo "  Ignoring this line"
    fi
  done
done
