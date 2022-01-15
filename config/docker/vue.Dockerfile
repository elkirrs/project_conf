FROM node:lts-alpine

# Set working directory
WORKDIR /var/www

RUN apk --update add --no-cache nano \
    make zip curl unzip

RUN npm i -g @vue/cli

ENTRYPOINT ["sh", '/var/scripts/vue.sh']
CMD ["tail", "-f", "/dev/null"]