ARG VERSION

FROM alpine:latest as gRPCPHPPlugin

RUN apk add --update --no-cache git cmake make linux-headers g++

# Generate plugin grpc_php_plugin
RUN cd / && git clone --recurse-submodules --depth 1 --shallow-submodules https://github.com/grpc/grpc && \
    cd grpc && mkdir cmake/build && cd cmake/build && \
    cmake ../.. && make protoc grpc_php_plugin && \
    cp /grpc/cmake/build/grpc_php_plugin /grpc_php_plugin


FROM php:$VERSION as backend

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
    && docker-php-ext-configure gd --with-freetype --with-jpeg --enable-gd \
    && pecl install amqp \
    && pecl install xdebug \
    && pecl install redis \
    && pecl install mongodb \
    && pecl install protobuf \
    && pecl install grpc \
    && docker-php-ext-enable amqp xdebug redis protobuf grpc mongodb

# Install extensions
RUN docker-php-ext-install -j$(nproc) gd \
    bz2 ctype intl bcmath opcache calendar \
    mbstring pgsql pdo_pgsql zip exif \
    pcntl sockets

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Copy grpc plugin
COPY --from=gRPCPHPPlugin /grpc_php_plugin /usr/grpc/grpc_php_plugin

# Clear cache
RUN rm -rf /var/lib/apk/* && rm -rf /var/cache/apk/*

RUN mv $PHP_INI_DIR/php.ini-development $PHP_INI_DIR/php.ini

EXPOSE 9000
ENTRYPOINT ["sh", "/var/scripts/php.sh"]
CMD ["tail", "-f", "/dev/null"]