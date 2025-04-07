#!/bin/bash
set -e

PGPASSWORD="$DTOCEAN_USER_PASSWORD"
psql -v ON_ERROR_STOP=1 --username "$DTOCEAN_USER_NAME" --dbname "$DTOCEAN_DB_EXAMPLES_NAME" -f schema.sql
psql -v ON_ERROR_STOP=1 --username "$DTOCEAN_USER_NAME" --dbname "$DTOCEAN_DB_TEMPLATE_NAME" -f schema.sql
