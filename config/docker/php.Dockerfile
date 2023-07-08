FROM php:8.2-fpm-alpine

# Set working directory
WORKDIR /var/www

# Install dependencies
RUN apk add --update --no-cache zip curl unzip libgd make cmake git \
    icu-dev libzip-dev libxml2-dev bzip2-dev \
    oniguruma-dev libmcrypt-dev readline-dev $PHPIZE_DEPS \
    libpng libjpeg-turbo freetype-dev libpng-dev jpeg-dev libjpeg libjpeg-turbo-dev \
    g++ supervisor nano libpq postgresql-dev \
    rabbitmq-c rabbitmq-c-dev protobuf-dev \
    imagemagick imagemagick-dev \
    grpc libstdc++ musl php-common linux-headers \
    && docker-php-ext-configure gd --with-freetype --with-jpeg --enable-gd \
    && pecl install amqp \
    && pecl install xdebug \
    && pecl install redis \
    && pecl install mongodb \
    && (yes | pecl install imagick) \
    && pecl install protobuf \
    && pecl install grpc \
    && docker-php-ext-enable amqp xdebug redis imagick protobuf grpc

# Install extensions
RUN docker-php-ext-install -j$(nproc) gd \
    bz2 ctype intl bcmath opcache calendar \
    mbstring pgsql pdo_pgsql xml zip exif \
    pcntl sockets
#    json tokenizer iconv

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Generate plugin grpc_php_plugin
RUN cd / && git clone --recurse-submodules --depth 1 --shallow-submodules https://github.com/grpc/grpc && \
    cd grpc && mkdir cmake/build && cd cmake/build && \
    cmake ../.. && make protoc grpc_php_plugin && \
    mkdir /usr/grpc && \
    cp /grpc/cmake/build/grpc_php_plugin /usr/grpc/grpc_php_plugin

# Clear cache
RUN rm -rf /var/lib/apk/* && rm -rf /var/cache/apk/* && rm -rf /grpc

RUN mv $PHP_INI_DIR/php.ini-development $PHP_INI_DIR/php.ini \
    && echo "extension=mongodb.so" >> /usr/local/etc/php/conf.d/docker-php-ext-mongodb.ini

EXPOSE 9000
ENTRYPOINT ["sh", "/var/scripts/php.sh"]
CMD ["tail", "-f", "/dev/null"]