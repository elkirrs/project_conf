#!/bin/sh
set -e

centrifugo -c config.json

exec "$@"