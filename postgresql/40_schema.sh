#!/bin/bash
set -e

psql -v ON_ERROR_STOP=1 --username "$DTOCEAN_USER" --password "$DTOCEAN_PASSWORD" --dbname "$DTOCEAN_DB_EXAMPLES_NAME" -f schema.sql
psql -v ON_ERROR_STOP=1 --username "$DTOCEAN_USER" --password "$DTOCEAN_PASSWORD" --dbname "$DTOCEAN_DB_TEMPLATE_NAME" -f schema.sql
