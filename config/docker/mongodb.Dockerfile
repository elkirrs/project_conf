ARG VERSION

FROM mongo:$VERSION

COPY ./config/mongodb/mongod.conf /etc/mongod.conf