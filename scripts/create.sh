#!/bin/sh

./build_sql_file.sh

psql -U postgres -c "DROP DATABASE socialgpsnetworks;"
psql -U postgres -c "CREATE DATABASE socialgpsnetworks WITH owner postgres TEMPLATE template0"
psql -c "CREATE EXTENSION IF NOT EXISTS postgis;" socialgpsnetworks
psql -c "CREATE EXTENSION IF NOT EXISTS hstore;" socialgpsnetworks

psql -f social_gps_networks.sql socialgpsnetworks

echo "socialgpsnetworks: import and db buildup finished"