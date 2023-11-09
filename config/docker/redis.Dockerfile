ARG VERSION

FROM redis:$VERSION

COPY /config/redis/redis.conf /etc/redis/redis.conf

EXPOSE 6379

CMD ["redis-server"]