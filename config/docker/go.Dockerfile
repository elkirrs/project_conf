FROM golang:alpine

RUN apk --update add --no-cache nano

WORKDIR /var/golang

COPY /golang /var/golang
#RUN go mod download

RUN mkdir -p /var/scripts
COPY /scripts/golang/go.sh /var/scripts/go.sh

ENTRYPOINT ["sh", "/var/scripts/go.sh"]