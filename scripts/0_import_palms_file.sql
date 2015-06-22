SET client_min_messages TO WARNING;

DROP TABLE IF EXISTS class_time_table_raw cascade;
CREATE TABLE class_time_table_raw (
  SchoolID	varchar,
  ClassID varchar,
--   School_Name_Layer varchar,
  Date timestamp without time zone,
--   day_of_week int2,
  School_start	timestamp without time zone,
  School_stop	timestamp without time zone,
  Recess1_start	timestamp without time zone,
  Recess1_stop	timestamp without time zone,
  Recess2_start	timestamp without time zone,
  Recess2_stop	timestamp without time zone,
  Recess3_start	timestamp without time zone,
  Recess3_stop	timestamp without time zone,
  Recess4_start	timestamp without time zone,
  Recess4_stop	timestamp without time zone
);

SET DATESTYLE TO 'SQL, MDY';

COPY Class_time_table_raw
FROM '/Users/besn/Dropbox/metascapes/Projects/palmsplus/scripts/odense/data/Class_time_table.csv'
WITH (FORMAT csv,
      DELIMITER ',',
      HEADER);

-- -- ----------------------------
-- -- Setup and import table participant_basis.
-- -- ----------------------------
DROP TABLE IF EXISTS participant_basis CASCADE;
CREATE TABLE participant_basis (
  identifier  varchar,
  schoolid	  varchar,
  classid     varchar
--   grade       int2
  );

COPY participant_basis
FROM '/Users/besn/Dropbox/metascapes/Projects/palmsplus/scripts/odense/data/participant_basis.csv'
WITH (FORMAT csv,
      DELIMITER ',',
      HEADER);

-- Table: palms_output
DROP TABLE IF EXISTS palms_output CASCADE;
CREATE TABLE palms_output
(
  identifier character varying(15),
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
FROM '/Users/besn/Dropbox/metascapes/Projects/palmsplus/scripts/odense/data/palms_output_560201.csv'
WITH (FORMAT csv,
      DELIMITER ',',
      HEADER);
