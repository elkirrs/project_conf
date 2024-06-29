ARG VERSION

FROM golang:$VERSION

RUN apk --update add --no-cache nano curl protobuf build-base sqlite-dev libpq postgresql-dev

WORKDIR /var/www/sso

RUN go install google.golang.org/protobuf/cmd/protoc-gen-go@latest && \
    go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest && \
    export PATH="$PATH:$(go env GOPATH)/bin"

EXPOSE 5462 5463 5464
ENTRYPOINT ["sh", "/var/scripts/go.sh"]
CMD ["tail", "-f", "/dev/null"]