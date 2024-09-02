ARG VERSION=v5.2

FROM centrifugo/centrifugo:${VERSION}

ENTRYPOINT ["sh", "/var/scripts/centrifugo.sh"]
CMD ["tail", "-f", "/dev/null"]