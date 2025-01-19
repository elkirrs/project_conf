#!/bin/sh
set -e

if [ -f /var/config/php/custom-php.ini ]; then
  echo "The custom php.ini file was found and moved"
  cp /var/config/php/custom-php.ini /usr/local/etc/php/conf.d/custom-php.ini
fi

if [ -f /var/config/php/register-pool.conf ]; then
  echo "The register-pool file was found and moved"
  cp /var/config/php/register-pool.conf /usr/local/etc/php-fpm.d/register-pool.conf
fi

php-fpm -D

protoc --version


if [ -f /var/config/supervisor/supervisord.conf ]; then
  echo "The supervisor config file was found and moved"
  cp /var/config/supervisor/supervisord.conf /etc/supervisor/supervisord.conf
  /usr/bin/supervisord -c /etc/supervisor/supervisord.conf
fi

exec "$@"
