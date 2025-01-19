#!/bin/sh

set -e

if [ -f /var/config/rr/rr.yaml ]; then
  echo "The rr.yaml config file was found and moved"
  cp /var/config/rr/rr.yaml /var/www/rr/rr.yaml

  /var/www/rr/rr serve -c /var/www/rr/rr.yaml
fi


exec "$@"