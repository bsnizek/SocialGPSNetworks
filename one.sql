
-- --
-- 2_table_config.sql
-- --
DROP TABLE IF EXISTS config;
DROP SEQUENCE IF EXISTS config_id_seq;
CREATE SEQUENCE config_id_seq;

DROP TABLE IF EXISTS config CASCADE;
CREATE TABLE config
(
  id int8 NOT NULL DEFAULT nextval('config_id_seq'),
  buffer_size float,
  time_threshold time,
  base_path varchar,
  source_file varchar
);

INSERT INTO config (buffer_size, time_threshold, source_file, base_path)
VALUES (30.0,
        '00:10:00',
        'palms_output_social_network_kild2012_test.csv',
        '/Users/besn/Projects/SocialGPSNetworks/');

-- --
-- 4_func_get_buffer_size.sql
-- --
CREATE OR REPLACE FUNCTION getBufferSize()
  RETURNS float AS
  $BODY$

  DECLARE

  f float;

  BEGIN

    SELECT buffer_size FROM config LIMIT 1 INTO f;

    RETURN f;

  END;$BODY$
LANGUAGE plpgsql VOLATILE
COST 100;

CREATE OR REPLACE FUNCTION getTimeTreshold()
  RETURNS time without time zone AS
  $BODY$

  DECLARE

  f time without time zone;

  BEGIN

    SELECT time_threshold FROM config LIMIT 1 INTO f;

    RETURN f;

  END;$BODY$
LANGUAGE plpgsql VOLATILE
COST 100;

CREATE OR REPLACE FUNCTION getBasePath()
  RETURNS varchar AS
  $BODY$

  DECLARE

  v varchar;

  BEGIN

    SELECT base_path FROM config LIMIT 1 INTO v;

    RETURN v;

  END;$BODY$
LANGUAGE plpgsql VOLATILE
COST 100;

CREATE OR REPLACE FUNCTION getSourceFile()
  RETURNS varchar AS
  $BODY$

  DECLARE

  v varchar;

  BEGIN

    SELECT source_file FROM config LIMIT 1 INTO v;

    RETURN v;

  END;$BODY$
LANGUAGE plpgsql VOLATILE
COST 100;


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


