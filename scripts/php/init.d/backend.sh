#!/bin/sh
set -e


if [ -d /var/www/backend/vendor ]; then

    if [ -f /var/scripts/proto.sh ] && [ -f /usr/grpc/grpc_php_plugin ]; then
      echo "Generated proto files"
      sh /var/scripts/proto.sh
    fi

    if [ -f /var/www/backend/artisan ]; then
      echo "PHP artisan file was found"
      chmod 777 -Rf /var/www/backend/storage

      if [ -d /var/logs/ ]; then
        chmod 777 -Rf /var/logs
      fi

      php /var/www/backend/artisan config:cache
      php /var/www/backend/artisan config:clear

    fi
fi


exec "$@"
