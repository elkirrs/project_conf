ARG VERSION=8.3-fpm-alpine

FROM alpine:latest AS grpc-php-plugin

RUN apk add --update --no-cache git cmake make linux-headers g++

# Generate plugin grpc_php_plugin
RUN cd / && git clone --recurse-submodules --depth 1 --shallow-submodules https://github.com/grpc/grpc && \
    cd grpc && mkdir cmake/build && cd cmake/build && \
    cmake ../.. && make protoc grpc_php_plugin && \
    cp /grpc/cmake/build/grpc_php_plugin /grpc_php_plugin


FROM php:${VERSION} AS grpc-php-ext

RUN apk add --update --no-cache zip unzip zlib-dev cmake make  \
    php-openssl php-pear linux-headers $PHPIZE_DEPS  \
    && pear channel-update pear.php.net \
    && pecl install grpc \
    && pecl install protobuf


FROM php:${VERSION} AS pecl-php-ext

RUN apk add --update --no-cache zip unzip zlib-dev cmake make  \
    php-openssl php-pear linux-headers $PHPIZE_DEPS \
    rabbitmq-c rabbitmq-c-dev \
    && pear channel-update pear.php.net \
    && pecl install amqp \
    && pecl install xdebug \
    && pecl install redis \
    && pecl install mongodb \
    && pecl install xhprof

FROM php:${VERSION} AS backend

# Set working directory
WORKDIR /var/www/php

# Install dependencies
RUN apk add --update --no-cache zip curl unzip cmake make \
    libzip-dev bzip2-dev \
    oniguruma-dev libmcrypt-dev readline-dev $PHPIZE_DEPS \
    g++ supervisor nano \
    libpq postgresql-dev \
    rabbitmq-c rabbitmq-c-dev \
    protobuf-dev grpc \
    libstdc++ musl php-common linux-headers \
    libgd libpng libjpeg-turbo freetype-dev libpng-dev jpeg-dev libjpeg libjpeg-turbo-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg --enable-gd

# Install extensions
RUN docker-php-ext-install -j$(nproc) gd \
    bz2 ctype intl bcmath opcache calendar \
    mbstring pgsql pdo_pgsql zip exif \
    pcntl sockets

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Copy grpc plugin
COPY --from=grpc-php-plugin /grpc_php_plugin /usr/grpc/grpc_php_plugin
COPY --from=grpc-php-ext /usr/local/lib/php/extensions/ /usr/local/lib/php/extensions/
COPY --from=pecl-php-ext /usr/local/lib/php/extensions/ /usr/local/lib/php/extensions/

RUN docker-php-ext-enable amqp xdebug redis protobuf grpc mongodb xhprof

# Clear cache
RUN rm -rf /var/lib/apk/* && rm -rf /var/cache/apk/*

RUN mv $PHP_INI_DIR/php.ini-development $PHP_INI_DIR/php.ini

EXPOSE 9000
ENTRYPOINT ["sh", "/var/scripts/php.sh"]
CMD ["tail", "-f", "/dev/null"]