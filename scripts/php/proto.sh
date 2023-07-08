#!/bin/sh

mkdir -p /var/www/vendor/protoout/src
rm -rf /var/www/vendor/protoout/src/*

protoc --proto_path=/var/proto \
    --php_out=/var/www/vendor/protoout/src \
    --grpc_out=/var/www/vendor/protoout/src \
    --plugin=protoc-gen-grpc=/usr/grpc/grpc_php_plugin \
    /var/proto/*

