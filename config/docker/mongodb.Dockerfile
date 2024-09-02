ARG VERSION=5.0

FROM mongo:${VERSION}

COPY ./config/mongodb/mongod.conf /etc/mongod.conf