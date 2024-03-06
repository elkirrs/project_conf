ARG VERSION

FROM php:$VERSION

# Set working directory
WORKDIR /var/www

RUN apk add --update --no-cache zip curl unzip make \
    icu-dev libzip-dev libxml2-dev bzip2-dev \
    oniguruma-dev libmcrypt-dev readline-dev $PHPIZE_DEPS \
    g++ nano php-common linux-headers libpq-dev postgresql-dev

RUN docker-php-ext-install bz2 ctype intl bcmath opcache calendar \
    mbstring xml zip exif pcntl sockets pdo pgsql pdo_pgsql

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN mv $PHP_INI_DIR/php.ini-development $PHP_INI_DIR/php.ini

EXPOSE 9010
ENTRYPOINT ["sh", "/var/scripts/chat.sh"]
CMD ["tail", "-f", "/dev/null"]