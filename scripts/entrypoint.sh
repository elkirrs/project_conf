#!/bin/sh

composer self-update

chmod 777 -Rf /var/www/storage
chmod 777 -Rf /var/logs

php /var/www/artisan config:cache || true
php /var/www/artisan config:clear || true
#php /var/www/sms-by/laravel/artisan migrate

php-fpm -D
/usr/bin/supervisord -c /etc/supervisor/supervisord.conf

# starts up supervisor
#* * * * * php /var/www/artisan schedule:run >> /dev/null 2>&1
exec "$@";