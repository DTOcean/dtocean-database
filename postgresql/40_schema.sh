#!/bin/bash
set -e

psql -v ON_ERROR_STOP=1 --username "$DTOCEAN_USER" --password "$DTOCEAN_PASSWORD" --dbname "$DTOCEAN_DB_NAME" -f schema.sql
