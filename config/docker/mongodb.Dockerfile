FROM mongo:latest

COPY ./config/mongodb.conf /etc/mongod.conf