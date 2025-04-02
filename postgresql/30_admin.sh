#!/bin/bash

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$DTOCEAN_DB_NAME" -f admin.sql
