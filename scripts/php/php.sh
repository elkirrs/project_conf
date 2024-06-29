#!/bin/sh
set -e

if [ -f /var/config/php/custom-php.ini ]; then
  echo "The custom php.ini file was found and moved"
  cp /var/config/php/custom-php.ini /usr/local/etc/php/conf.d/custom-php.ini
fi

php-fpm -D

if [ -d /var/www/php/vendor ]; then

    if [ -f /var/config/supervisor/supervisord.conf ]; then
      echo "The supervisor config file was found and moved"
      cp /var/config/supervisor/supervisord.conf /etc/supervisor/supervisord.conf
      /usr/bin/supervisord -c /etc/supervisor/supervisord.conf
    fi

    if [ -f /var/scripts/proto.sh ] && [ -f /usr/grpc/grpc_php_plugin ]; then
      echo "Generated proto files"
      sh /var/scripts/proto.sh
    fi

    protoc --version
    composer self-update

    if [ -f /var/www/php/artisan ]; then
      echo "PHP artisan file was found"
      chmod 777 -Rf /var/www/php/storage

      if [ -d /var/logs/ ]; then
        chmod 777 -Rf /var/logs
      fi

      php /var/www/php/artisan config:cache
      php /var/www/php/artisan config:clear

    fi

    if [ -f /var/www/php/composer.json ]; then
      composer du
    fi
fi


exec "$@"
