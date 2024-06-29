#!/bin/sh

mkdir -p /var/www/php/vendor/protoout/src
rm -rf /var/www/php/vendor/protoout/src/*

protoc --proto_path=/var/proto \
    --php_out=/var/www/php/vendor/protoout/src \
    --grpc_out=/var/www/php/vendor/protoout/src \
    --plugin=protoc-gen-grpc=/usr/grpc/grpc_php_plugin \
    /var/proto/*

