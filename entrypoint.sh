#!/bin/sh
set -e

echo "Waiting for database at $PGHOST:$PGPORT..."
while ! nc -z "$PGHOST" "$PGPORT"; do
    sleep 1
done
echo "Database active!"

mix ecto.create
mix ecto.migrate

exec mix phx.server