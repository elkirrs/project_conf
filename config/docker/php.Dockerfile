FROM php:8.1-fpm-alpine
# Set working directory
WORKDIR /var/www

# Install dependencies
RUN apk --update add --no-cache htop zip curl unzip libgd \
    icu-dev libzip-dev libxml2-dev bzip2-dev \
    libjpeg-turbo libmcrypt-dev readline-dev freetype libpng $PHPIZE_DEPS \
    freetype-dev libpng-dev libjpeg-turbo-dev make oniguruma-dev \
    g++ supervisor nano libpq postgresql-dev rabbitmq-c rabbitmq-c-dev \
    imagemagick imagemagick-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd \
    && pecl install amqp && docker-php-ext-enable amqp \
    && pecl install xdebug && docker-php-ext-enable xdebug \
    && pecl install redis && docker-php-ext-enable redis \
    && pecl install mongodb
#    && (yes | pecl install imagick) && docker-php-ext-enable imagick

# Clear cache
RUN rm -rf /var/lib/apk/* && rm -rf /var/cache/apk/*

# Install extensions
RUN docker-php-ext-install bz2 ctype intl iconv \
    bcmath opcache calendar mbstring pgsql \
    pdo_pgsql xml zip exif pcntl gd
#    json tokenizer sockets

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

COPY /config/supervisor/supervisord.conf /etc/supervisor/supervisord.conf

RUN mv /usr/local/etc/php/php.ini-development /usr/local/etc/php/php.ini
RUN echo "extension=mongodb.so" >> /usr/local/etc/php/conf.d/docker-php-ext-mongodb.ini

COPY /config/php/custom-php.ini /usr/local/etc/php/conf.d/custom-php.ini

ENTRYPOINT ["sh", "/var/scripts/php.sh"]
CMD ["tail", "-f", "/dev/null"]