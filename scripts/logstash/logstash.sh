#!/bin/sh
set -e

if [ -f /var/config/logstash/logstash.yml ]; then
  echo "The custom logstash yml file was found and moved"
  cp /var/config/logstash/logstash.yml /usr/share/logstash/config/logstash.yml
fi

logstash -f /usr/share/logstash/pipeline/logstash.conf

exec "$@"