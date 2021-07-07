FROM nginx:alpine

RUN apk --update add --no-cache nano openssl

RUN rm -fr /etc/nginx/conf.d/default.conf \
    && rm -rf /var/lib/apk/* \
    && rm -rf /var/cache/apk/*