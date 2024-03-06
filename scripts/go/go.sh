#!/bin/sh
set -e

if [ ! -d /var/log ]; then
  echo  "Created log directory"
  mkdir /var/log
fi

chmod 777 -Rf /var/log

if [ ! -f /var/www/sso/go.mod ]; then
  cd /var/www/sso
  go mod init app
fi

#if [ -f /var/www/cmd/main.go ]; then
#  go build -v ./cmd/main.go
#fi

if [ -d /var/proto ] && [ -f /var/scripts/proto.sh ]; then
  sh /var/scripts/proto.sh
fi

go version
protoc --version
echo "Starting golang"

exec "$@"