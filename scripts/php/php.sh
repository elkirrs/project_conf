#!/bin/sh
set -e

if [ -f /var/config/php/custom-php.ini ]; then
  echo "The custom php.ini file was found and moved"
  cp /var/config/php/custom-php.ini /usr/local/etc/php/conf.d/custom-php.ini
fi

if [ -f /var/config/supervisor/supervisord.conf ]; then
  echo "The supervisor config file was found and moved"
  cp /var/config/supervisor/supervisord.conf /etc/supervisor/supervisord.conf
fi

if [ -f /var/scripts/proto.sh ] && [ -f /usr/grpc/grpc_php_plugin ]; then
  echo "Generated proto files"
  sh /var/scripts/proto.sh
fi

protoc --version
composer self-update
php-fpm -D

if [ -f /var/www/artisan ]; then
  echo "PHP artisan file was found"
  chmod 777 -Rf /var/www/storage

  if [ -d /var/logs/ ]; then
    chmod 777 -Rf /var/logs
  fi

  php /var/www/artisan config:cache
  php /var/www/artisan config:clear

  /usr/bin/supervisord -c /etc/supervisor/supervisord.conf
fi

if [ -f /var/www/composer.json ]; then
  composer du
fi

exec "$@"
