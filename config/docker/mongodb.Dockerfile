FROM mongo:latest

COPY ./config/mongodb/mongod.conf /etc/mongod.conf