#!/bin/bash
set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$DTOCEAN_DB_EXAMPLES_NAME" -f admin.sql
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$DTOCEAN_DB_TEMPLATE_NAME" -f admin.sql
