#!/bin/sh
set -e

echo "Running init scripts..."
chmod +x /var/scripts/init.d/*

for file in /var/scripts/init.d/*; do
    if [ -x "$file" ]; then
        echo "Executing $file..."
        "$file"
    else
        echo "Ignoring $file (not executable)"
    fi
done

echo "Init scripts completed."

exec "$@"