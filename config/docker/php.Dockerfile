ARG VERSION=8.4-fpm-alpine
ARG RR_VERSION=2024.1.5

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

FROM ghcr.io/roadrunner-server/roadrunner:${RR_VERSION} AS roadrunner

FROM php:${VERSION} AS backend

# Set working directory
WORKDIR /var/www

# Install dependencies
RUN apk add --update --no-cache zip curl unzip cmake make \
    libzip-dev bzip2-dev icu-dev libxml2-dev \
    oniguruma-dev libmcrypt-dev readline-dev $PHPIZE_DEPS \
    g++ supervisor nano \
    libpq postgresql-dev libpq-dev\
    rabbitmq-c rabbitmq-c-dev \
    protobuf-dev grpc \
    libstdc++ musl php-common linux-headers \
    libgd libpng libjpeg-turbo freetype-dev libpng-dev jpeg-dev libjpeg libjpeg-turbo-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg --enable-gd \
    # Install extensions
    && docker-php-ext-install -j$(nproc) gd bz2 ctype intl bcmath opcache calendar \
    mbstring xml exif pgsql pdo_pgsql zip exif pcntl sockets pdo \
    # Clear cache
    && rm -rf /var/cache/apk/*

# Copy grpc plugin
COPY --from=grpc-php-plugin /grpc_php_plugin /usr/grpc/grpc_php_plugin
COPY --from=grpc-php-ext /usr/local/lib/php/extensions/ /usr/local/lib/php/extensions/
COPY --from=pecl-php-ext /usr/local/lib/php/extensions/ /usr/local/lib/php/extensions/
COPY --from=roadrunner /usr/bin/rr /var/www/rr/rr

RUN docker-php-ext-enable amqp xdebug redis protobuf grpc mongodb xhprof

RUN mv $PHP_INI_DIR/php.ini-development $PHP_INI_DIR/php.ini \
    # Install composer
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

EXPOSE 9000 9100
ENTRYPOINT ["sh", "/var/scripts/init.sh"]
CMD ["tail", "-f", "/dev/null"]