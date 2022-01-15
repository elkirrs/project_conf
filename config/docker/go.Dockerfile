FROM golang:alpine

RUN apk --update add --no-cache nano curl

WORKDIR /var/www

ENTRYPOINT ["sh", "/var/scripts/go.sh"]
CMD ["tail", "-f", "/dev/null"]