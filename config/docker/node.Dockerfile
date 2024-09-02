ARG VERSION=lts-alpine

FROM node:${VERSION}

# Set working directory
WORKDIR /var/www

RUN apk --update add --no-cache nano \
    make zip curl unzip

ENTRYPOINT ["sh", "/var/scripts/node.sh"]
CMD ["tail", "-f", "/dev/null"]