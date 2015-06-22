#!/bin/sh

./build-final-odense.sh
psql -U postgres -c "DROP DATABASE odense;"
psql -U postgres -c "CREATE DATABASE odense WITH owner postgres TEMPLATE template0"
psql -c "CREATE EXTENSION IF NOT EXISTS postgis;" odense
psql -c "CREATE EXTENSION IF NOT EXISTS hstore;" odense

psql -f 0_import_csv_files_odense.sql odense

psql -f 1-palmsplus.sql odense
psql -f 2-palmsplus.sql odense
psql -f 3-palmsplus.sql odense
psql -f 4-palmsplus.sql odense

echo "Holland: import and db buildup finished"