#!/bin/sh

# Run scheduler
while [ true ]
do
  php artisan schedule:run --verbose --no-interaction || true
  sleep 60
done