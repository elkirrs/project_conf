#!/bin/sh
set -e

if [ ! -f /etc/nginx/listen/localhost.crt ]; then
    cd /etc/nginx/listen/
    openssl req -x509 -out localhost.crt -keyout localhost.key \
      -newkey rsa:2048 -nodes -sha256 -days 365 \
      -subj '/CN=localhost' -extensions EXT -config <( \
       printf "[dn]\nCN=localhost\n[req]\ndistinguished_name = dn\n[EXT]\nsubjectAltName=DNS:localhost\nkeyUsage=digitalSignature\nextendedKeyUsage=serverAuth")

    # Long lime generate
#    openssl dhparam -out dhparam.pem 4096
fi

exec "$@"