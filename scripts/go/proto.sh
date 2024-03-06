#!/bin/sh

mkdir -p /var/www/sso/pkg/api/grpc
rm -rf /var/www/sso/pkg/api/grpc/*

protoc --go_out=/var/www/sso/pkg/api/grpc \
  --go_opt=paths=source_relative \
  --go-grpc_out=require_unimplemented_servers=false:/var/www/sso/pkg/api/grpc \
  --go-grpc_opt=paths=source_relative \
  --proto_path=/var/proto/auth \
  /var/proto/auth/*
