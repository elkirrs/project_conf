#!/bin/sh
set -e

composer self-update

php-fpm -D

if [ -f /var/www/artisan ]; then
  echo "php artisan exist"
  chmod 777 -Rf /var/www/storage

  if [ -d /var/logs/ ]; then
    chmod 777 -Rf /var/logs
  fi

  php /var/www/artisan config:cache
  php /var/www/artisan config:clear

  /usr/bin/supervisord -c /etc/supervisor/supervisord.conf
fi

exec "$@"
