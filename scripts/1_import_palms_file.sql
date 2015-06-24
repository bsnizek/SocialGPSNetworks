-- --
-- 1_import_palms_file.sql
-- --
SET client_min_messages TO WARNING;
-- Table: palms_output
DROP TABLE IF EXISTS palms_output CASCADE;
CREATE TABLE palms_output
(
  identifier int8,
  palms_datetime timestamp without time zone,
  dow integer,
  lat double precision,
  lon double precision,
  fixtypecode smallint,
  iov integer,
  tripnumber integer,
  triptype integer,
  tripmot integer,
  activity integer,
  activityintensity smallint,
  activityboutnumber smallint,
  sedentaryboutnumber smallint
)
WITH (
  OIDS=FALSE
);

COPY palms_output
FROM '/Users/besn/Projects/SocialGPSNetworks/scripts/palms_output_social_network_kild2012_test.csv'
WITH (FORMAT csv,
      DELIMITER ',',
      HEADER);
