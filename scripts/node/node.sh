#!/bin/sh
set -e


if [ -f /var/www/package.json ]; then
  echo "package.json exist"
  cd /var/www
  npm i
fi

exec "$@"