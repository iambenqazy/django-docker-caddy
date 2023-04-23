#!/bin/sh

set -e

if [ "$DB_NAME" = "csmsdb" ]; then
    echo "Waiting for postgres..."

    while ! nc -z $DB_HOST $DB_PORT; do
      sleep 0.1
    done

    echo "PostgreSQL started"
fi

exec "$@"