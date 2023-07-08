#!/bin/sh

mkdir -p /var/www/pkg/api/grpc
rm -rf /var/www/pkg/api/grpc/*

protoc --go_out=/var/www/pkg/api/grpc \
  --go_opt=paths=source_relative \
  --go-grpc_out=require_unimplemented_servers=false:/var/www/pkg/api/grpc \
  --go-grpc_opt=paths=source_relative \
  --proto_path=/var/proto \
  /var/proto/*
