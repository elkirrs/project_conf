#!/bin/sh
set -e

if [ -f /var/config/logstash/logstash-custom.conf ]; then
  echo "The custom logstash config file was found and moved"
  cp /var/config/logstash/logstash-custom.conf /usr/share/logstash/config/logstash-custom.conf
fi

exec "$@"