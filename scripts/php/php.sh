#!/bin/sh
set -e

composer self-update

php-fpm -D

if [ -f /var/www/artisan ]; then
  echo "php artisan exist"
  chmod 777 -Rf /var/www/storage
  chmod 777 -Rf /var/logs

  php /var/www/artisan config:cache
  php /var/www/artisan config:clear

  /usr/bin/supervisord -c /etc/supervisor/supervisord.conf
fi

exec "$@"
