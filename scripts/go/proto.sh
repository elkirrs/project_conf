#!/bin/sh

mkdir -p /var/www/sso/pkg/grpc
rm -rf /var/www/sso/pkg/grpc/*

protoc --go_out=/var/www/sso/pkg/grpc \
  --go_opt=paths=source_relative \
  --go-grpc_out=require_unimplemented_servers=false:/var/www/sso/pkg/grpc \
  --go-grpc_opt=paths=source_relative \
  --proto_path=/var/proto \
  /var/proto/*