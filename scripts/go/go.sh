#!/bin/sh
set -e

if [ ! -d /var/log ]; then
  echo  "Created log directory"
  mkdir /var/log
fi

chmod 777 -Rf /var/log

go version

if [ ! -f /var/www/go.mod ]; then
  echo "Init golang mod 'github.com/gorilla/mux.git'"
  go mod init github.com/gorilla/mux.git
fi

if [ -f /var/www/cmd/main.go ]; then
#  go build -v cmd
  go run cmd/main.go
fi

echo "Starting golang"

exec "$@"