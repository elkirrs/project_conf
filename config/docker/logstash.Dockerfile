ARG VERSION

FROM logstash:$VERSION

ENTRYPOINT ["sh", "/var/scripts/logstash.sh"]
CMD ["tail", "-f", "/dev/null"]