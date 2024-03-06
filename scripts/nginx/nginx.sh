#!/bin/sh
set -e

if [ ! -f /etc/nginx/listen/app.crt ]; then
    cd /etc/nginx/listen/

    openssl req -x509 -out app.crt -keyout app.key \
      -newkey rsa:4096 -nodes -sha256 \
      -days 365 \
      -subj '/CN=localhost' \
      -extensions EXT \
      -config <( printf "[dn]\nCN=localhost\n[req]\ndistinguished_name = dn\n[EXT]\nsubjectAltName=DNS:localhost\nkeyUsage=digitalSignature\nextendedKeyUsage=serverAuth")

    #Long lime generate
#    openssl dhparam -out dhparam.pemKeys 4096
fi

exec "$@"