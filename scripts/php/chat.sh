#!/bin/sh
set -e

if [ -f /var/config/php/chat-php.ini ]; then
  echo "The chat config php.ini file was found and moved"
  cp /var/config/php/chat-php.ini /usr/local/etc/php/conf.d/chat-php.ini
fi

if [ -f /var/config/rr/rr.yaml ]; then
  echo "The chat config php.ini file was found and moved"
  cp /var/config/rr/rr.yaml /var/www/rr.yaml
fi

composer self-update

if [ -f /var/www/composer.json ]; then
  composer du
fi

#if [ -d /var/www/vendor ]; then
#  ./rr serve -c rr.yaml
#fi

exec "$@"
