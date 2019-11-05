#!/usr/bin/env bash
clear

if [[ -f .lastHost ]]; then
  lastHost=$(cat .lastHost)
else
  lastHost="Nenhum"
  echo $lastHost > .lastHost
fi

receive_data() {
  read data
  if ! [ -z "$data" ]; then
    echo "Got some data: $data"
    ip=$(echo $data | grep -Eo '([0-9]{1,3}\.){3}([0-9]{1,3})')
    if ! [ -z "$ip" ]; then
      echo "Sending installer to IP: $ip"
      sshpass -p "$pass" scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null $file "$user"@"$ip":~/
      lastHost="$ip"
      echo $lastHost > .lastHost
    else
      echo "Got junk data, ignoring."
    fi
  fi
  echo -e "\n"
}

listen() {
  nc -l "$port" | receive_data
}

main() {

  echo "Listening on :$port"
  echo "Serving file: $file"
  echo ""
  echo "Last host: $lastHost"
  echo ""


  while true; do
    listen
  done

}

port="4789"
user="admin"
pass="admin"
file=""

while true; do
  case "$1" in
    --port)
      shift
      port=$1
      shift
    ;;
    --user)
      shift
      #echo "user: $1"
      user=$1
      shift
    ;;
    --pass)
      shift
      #echo "pass: $1"
      pass=$1
      shift
    ;;
    *)
      #echo $1
      file=$1
      if [ -z "$file" ]; then
        echo "You need to provide a file to send!"
        echo "Usage: bash installer_sender.sh [OPTIONS] [FILE]"
        exit 1
      fi
      main
    ;;
  esac
done
