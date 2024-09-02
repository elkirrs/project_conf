ARG VERSION=7.17.22

FROM logstash:$VERSION

ENTRYPOINT ["sh", "/var/scripts/logstash.sh"]
CMD ["tail", "-f", "/dev/null"]