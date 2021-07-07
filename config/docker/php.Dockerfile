FROM php:7.4-fpm-alpine

# Set working directory
WORKDIR /var/www

# Install dependencies
RUN apk --update add --no-cache htop zip curl unzip libgd \
    icu-dev libzip-dev libxml2-dev bzip2-dev \
    libjpeg-turbo libmcrypt-dev readline-dev freetype libpng $PHPIZE_DEPS \
    freetype-dev libpng-dev libjpeg-turbo-dev make oniguruma-dev \
    g++ supervisor npm nano libpq postgresql-dev rabbitmq-c rabbitmq-c-dev \
    imagemagick imagemagick-dev libmemcached-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd \
    && pecl install amqp && docker-php-ext-enable amqp \
    && pecl install xdebug && docker-php-ext-enable xdebug \
    && pecl install redis && docker-php-ext-enable redis \
    && (yes | pecl install imagick-3.4.3) && docker-php-ext-enable imagick

# Clear cache
RUN rm -rf /var/lib/apk/* && rm -rf /var/cache/apk/*

# Install extensions
RUN docker-php-ext-install bz2 ctype json intl iconv \
    bcmath opcache calendar mbstring pgsql \
    pdo_pgsql tokenizer xml zip exif pcntl gd sockets
#    pdo_mysql

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Copy existing application directory contents
COPY . /var/www

RUN mkdir -p /var/scripts
# Copy existing application directory permissions
COPY /config/supervisor/supervisord.conf /etc/supervisor/supervisord.conf
COPY /scripts /var/scripts

# Expose port 9000 and start php-fpm server
EXPOSE 9000
ENTRYPOINT ["sh", "/var/scripts/entrypoint.sh"]