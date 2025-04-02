FROM postgis/postgis
COPY admin.sql schema.sql /
COPY 20_user.sh 30_admin.sh 40_schema.sh 50_restore.sh /docker-entrypoint-initdb.d/
