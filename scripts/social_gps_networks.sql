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
-- 3_view_palms_output_geom.sql
-- --
DROP MATERIALIZED VIEW IF EXISTS palms_output_geom CASCADE;

DROP SEQUENCE IF EXISTS palms_output_geom_uid_seq;
CREATE SEQUENCE palms_output_geom_uid_seq START 1;

CREATE MATERIALIZED VIEW palms_output_geom AS
  SELECT
    nextval('palms_output_geom_uid_seq') AS uid,

    (identifier || '-' || tripnumber || '-' || to_char(palms_datetime::date,'YYYYMMDD')) AS unique_trip_id,

    identifier,

    ST_Transform(
        ST_SetSRID(
            ST_Makepoint(palms_output.lon,
                         palms_output.lat), 4326),
        4326) AS geom,

    palms_datetime,
    lat,
    lon
  -- ,*
  FROM palms_output

  WHERE lat > -180 AND lon > -180;

DROP INDEX IF EXISTS palms_output_geom_idx;
CREATE UNIQUE INDEX palms_output_geom_idx
ON palms_output_geom (uid);

DROP INDEX IF EXISTS gidx_palms_output_geom;
CREATE INDEX gidx_palms_output_geom ON palms_output_geom USING GIST (geom);

DROP INDEX IF EXISTS idx_palms_output_identifier;
CREATE INDEX  "idx_palms_output_identifier" ON palms_output_geom USING BTREE (identifier);

DROP INDEX IF EXISTS idx_palms_output_unique_trip_id;
CREATE INDEX  "idx_palms_output_unique_trip_id" ON palms_output_geom USING BTREE (unique_trip_id);

DROP INDEX IF EXISTS idx_palms_output_datetime;
CREATE INDEX  "idx_palms_output_datetime" ON palms_output_geom USING BTREE (palms_datetime);

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
-- 5_table_vicinity.sql
-- --
DROP TABLE IF EXISTS vicinity;
DROP SEQUENCE IF EXISTS vicinity_id_seq;
CREATE SEQUENCE vicinity_id_seq;

DROP TABLE IF EXISTS vicinity CASCADE;
CREATE TABLE vicinity
(
  id serial primary key,
  geom geometry,
  person1 int8,
  person2 int8,
  palms_datetime timestamp without time zone,
  distance float
);

COMMIT;

-- --
-- 6_view_timesteps.sql
-- --
DROP MATERIALIZED VIEW IF EXISTS timesteps CASCADE;

CREATE MATERIALIZED VIEW timesteps AS
  SELECT palms_datetime
  FROM palms_output
  GROUP BY palms_datetime
  ORDER BY palms_datetime
  ASC;

DROP MATERIALIZED VIEW IF EXISTS days CASCADE;

CREATE MATERIALIZED VIEW days AS
  SELECT palms_datetime::date
  FROM timesteps G
  GROUP BY palms_datetime::date
  ORDER BY palms_datetime::date
  ASC;

-- --
-- 7_view_person_identifiers.sql
-- --
DROP MATERIALIZED VIEW IF EXISTS person_identifiers CASCADE;

CREATE MATERIALIZED VIEW person_identifiers AS
  SELECT identifier
  FROM palms_output
  GROUP BY identifier
  ORDER BY identifier
  ASC;

-- --
-- 8_func_create_vicinity.sql
-- --
CREATE OR REPLACE FUNCTION create_vicinity()
  RETURNS varchar AS
  $BODY$DECLARE

    r1 palms_output_geom%rowtype;
    t timesteps%rowtype;

    person_identifiers int8[];

    distance float;
    ins varchar;

    k bigint;
    n_timesteps bigint;
    n_persons bigint;

    p1 varchar;
    p2 varchar;

    person_identifier int8;

    q varchar := '''';
    x int2;

    current_person_geom geometry;
    center_geometry geometry;

    i integer := 0;

  BEGIN

    EXECUTE 'DELETE FROM  vicinity;';

    SELECT count(*) from palms_output_geom INTO k;
    SELECT count(*) FROM timesteps INTO n_timesteps;
    SELECT count(*) FROM person_identifiers INTO n_persons;

    RAISE NOTICE '% timesteps.', n_timesteps;
    RAISE NOTICE '% persons.', n_persons;

    FOR t IN SELECT * FROM timesteps LOOP

      RAISE NOTICE '% / % !', i, n_timesteps;

      FOR person_identifier IN SELECT identifier FROM person_identifiers LOOP

        SELECT geom from palms_output_geom
        WHERE identifier=person_identifier AND palms_datetime=t.palms_datetime
        INTO current_person_geom;

        FOR r1 IN

        SELECT * FROM palms_output_geom

        WHERE
          palms_datetime = t.palms_datetime
          AND
          ST_Distance_Sphere(geom , current_person_geom) < getBufferSize()
          AND identifier != person_identifier

        LOOP

          if r1.identifier != person_identifier THEN

            center_geometry := ST_Line_Interpolate_Point(ST_MakeLine(current_person_geom, r1.geom), 0.5);
            distance := ST_Distance(current_person_geom, r1.geom);

            BEGIN

              SELECT count(*) FROM vicinity WHERE person1=r1.identifier AND person2=person_identifier AND palms_datetime=t.palms_datetime INTO x;

              IF x=0 THEN

                EXECUTE 'INSERT INTO vicinity (geom, person1, person2, distance, palms_datetime) VALUES ('
                        || q || center_geometry::varchar || q || ','
                        || person_identifier || ','
                        || r1.identifier || ','
                        || distance || ',' || q
                        || t.palms_datetime || q || ');';

              END IF;

            END;
          END IF;

        END LOOP;
      END LOOP;

      i := i + 1;

    END LOOP;

    RAISE NOTICE 'FINISHED !';

    RETURN 'create_vicinity() finished!';

  END;$BODY$
LANGUAGE plpgsql VOLATILE
COST 1;


-- --
-- 9_remove_doublettes.sql
-- --
CREATE OR REPLACE FUNCTION remove_doublettes()
  RETURNS varchar AS
  $BODY$DECLARE

    r1 vicinity%rowtype;


  BEGIN

    FOR r1 IN SELECT * FROM vicinity LOOP

      -- RAISE NOTICE '%', r1;

      DELETE FROM vicinity WHERE person1=r1.person2 AND person2=r1.person1 and palms_datetime=r1.palms_datetime;

    END LOOP;

    RETURN 'sexy!';

  END;$BODY$
LANGUAGE plpgsql VOLATILE
COST 1;

-- --
-- 10_func_create_meetings.sql
-- --
CREATE OR REPLACE FUNCTION create_meetings()
  RETURNS varchar AS
  $BODY$DECLARE

    r1 vicinity%rowtype;
    r2 vicinity%rowtype;
    t timesteps%rowtype;

    p1 person_identifiers%rowtype;
    p2 person_identifiers%rowtype;

    gg geometry[];
    g geometry;

    k bigint;
    n bigint;

    q varchar := '''';

    status smallint  := 0;
    c smallint;

    begin_time timestamp without time zone;

    polyline geometry;

  BEGIN

    EXECUTE 'DELETE FROM  meeting;';

    RAISE NOTICE 'Starting.';

    SELECT count(*) from vicinity INTO k;

    RAISE NOTICE '%', k;

    FOR p1 IN SELECT * FROM person_identifiers LOOP
      FOR p2 IN SELECT * FROM person_identifiers LOOP

        RAISE NOTICE '% <-> %', p1.identifier, p2.identifier;

        FOR t IN SELECT * FROM timesteps LOOP

          SELECT count(*) FROM vicinity
          WHERE palms_datetime = t.palms_datetime
                AND person1 = p1.identifier
                AND person2 = p2.identifier
          INTO c;

          IF c = 1 AND status = 0 THEN
            SELECT geom
            FROM vicinity
            WHERE palms_datetime=t.palms_datetime
                  AND person1=p1.identifier
                  AND person2=p2.identifier INTO g;
            begin_time := t.palms_datetime;
            status = 1;             -- we are now inside a meeting
            gg = array[]::geometry[];
            gg = array_append(gg, g);
          END IF;

          IF c = 1 AND status = 1 THEN
            SELECT geom
            FROM vicinity
            WHERE palms_datetime=t.palms_datetime
                  AND person1=p1.identifier
                  AND person2=p2.identifier INTO g;
            gg = array_append(gg, g);
          END IF;

          IF c = 0 AND status = 1 THEN
            polyline = ST_Makeline(gg);
            status = 0;
            EXECUTE 'INSERT INTO meeting (geom, person1, person2, begin_time, end_time, duration) VALUES ('
                    || q || polyline::varchar || q || ','
                    || p1.identifier || ','
                    || p2.identifier || ',' || q
                    || begin_time || q || ',' || q
                    || t.palms_datetime || q || ',' || q
                    || t.palms_datetime - begin_time || q || ');';
          END IF;

        END LOOP;
      END LOOP;
    END LOOP;

    RAISE NOTICE 'FINISHED !';

    RETURN 'create_meetings() finished !';

  END;$BODY$
LANGUAGE plpgsql VOLATILE
COST 1;

-- --
-- 11_add_indexes.sql
-- --
DROP INDEX IF EXISTS idx_palms_vicinity_person_one;
CREATE INDEX  "idx_palms_vicinity_person_one" ON vicinity USING BTREE (person1);

DROP INDEX IF EXISTS idx_palms_vicinity_person_two;
CREATE INDEX  "idx_palms_vicinity_person_two" ON vicinity USING BTREE (person2);

DROP INDEX IF EXISTS idx_palms_vicinity_palms_datetime;
CREATE INDEX  "idx_palms_vicinity_palms_datetime" ON vicinity USING BTREE (palms_datetime);

DROP INDEX IF EXISTS idx_person_identifiers;
CREATE INDEX  "idx_person_identifiers" ON person_identifiers USING BTREE (identifier);

DROP INDEX IF EXISTS idx_timesteps;
CREATE INDEX  "idx_timesteps" ON timesteps USING BTREE (palms_datetime);

-- --
-- 12_table_meeting.sql
-- --

DROP TABLE IF EXISTS meeting;
DROP SEQUENCE IF EXISTS meeting_id_seq;
CREATE SEQUENCE meeting_id_seq;

DROP TABLE IF EXISTS meeting CASCADE;
CREATE TABLE meeting
(
  id serial primary key,
  geom geometry,
  person1 int8,
  person2 int8,
  begin_time timestamp without time zone,
  end_time timestamp without time zone,
  duration interval
);

COMMIT;

-- --
-- 13_create_data.sql
-- --

SELECT * FROM create_vicinity();
COMMIT;
--SELECT * FROM remove_doublettes();
SELECT * FROM create_meetings();

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
-- 3_view_palms_output_geom.sql
-- --
DROP MATERIALIZED VIEW IF EXISTS palms_output_geom CASCADE;

DROP SEQUENCE IF EXISTS palms_output_geom_uid_seq;
CREATE SEQUENCE palms_output_geom_uid_seq START 1;

CREATE MATERIALIZED VIEW palms_output_geom AS
  SELECT
    nextval('palms_output_geom_uid_seq') AS uid,

    (identifier || '-' || tripnumber || '-' || to_char(palms_datetime::date,'YYYYMMDD')) AS unique_trip_id,

    identifier,

    ST_Transform(
        ST_SetSRID(
            ST_Makepoint(palms_output.lon,
                         palms_output.lat), 4326),
        4326) AS geom,

    palms_datetime,
    lat,
    lon
  -- ,*
  FROM palms_output

  WHERE lat > -180 AND lon > -180;

DROP INDEX IF EXISTS palms_output_geom_idx;
CREATE UNIQUE INDEX palms_output_geom_idx
ON palms_output_geom (uid);

DROP INDEX IF EXISTS gidx_palms_output_geom;
CREATE INDEX gidx_palms_output_geom ON palms_output_geom USING GIST (geom);

DROP INDEX IF EXISTS idx_palms_output_identifier;
CREATE INDEX  "idx_palms_output_identifier" ON palms_output_geom USING BTREE (identifier);

DROP INDEX IF EXISTS idx_palms_output_unique_trip_id;
CREATE INDEX  "idx_palms_output_unique_trip_id" ON palms_output_geom USING BTREE (unique_trip_id);

DROP INDEX IF EXISTS idx_palms_output_datetime;
CREATE INDEX  "idx_palms_output_datetime" ON palms_output_geom USING BTREE (palms_datetime);

-- --
-- 5_table_vicinity.sql
-- --
DROP TABLE IF EXISTS vicinity;
DROP SEQUENCE IF EXISTS vicinity_id_seq;
CREATE SEQUENCE vicinity_id_seq;

DROP TABLE IF EXISTS vicinity CASCADE;
CREATE TABLE vicinity
(
  id serial primary key,
  geom geometry,
  person1 int8,
  person2 int8,
  palms_datetime timestamp without time zone,
  distance float
);

COMMIT;

-- --
-- 6_view_timesteps.sql
-- --
DROP MATERIALIZED VIEW IF EXISTS timesteps CASCADE;

CREATE MATERIALIZED VIEW timesteps AS
  SELECT palms_datetime
  FROM palms_output
  GROUP BY palms_datetime
  ORDER BY palms_datetime
  ASC;

DROP MATERIALIZED VIEW IF EXISTS days CASCADE;

CREATE MATERIALIZED VIEW days AS
  SELECT palms_datetime::date
  FROM timesteps G
  GROUP BY palms_datetime::date
  ORDER BY palms_datetime::date
  ASC;

-- --
-- 7_view_person_identifiers.sql
-- --
DROP MATERIALIZED VIEW IF EXISTS person_identifiers CASCADE;

CREATE MATERIALIZED VIEW person_identifiers AS
  SELECT identifier
  FROM palms_output
  GROUP BY identifier
  ORDER BY identifier
  ASC;

-- --
-- 8_func_create_vicinity.sql
-- --
CREATE OR REPLACE FUNCTION create_vicinity()
  RETURNS varchar AS
  $BODY$DECLARE

    r1 palms_output_geom%rowtype;
    t timesteps%rowtype;

    person_identifiers int8[];

    distance float;
    ins varchar;

    k bigint;
    n_timesteps bigint;
    n_persons bigint;

    p1 varchar;
    p2 varchar;

    person_identifier int8;

    q varchar := '''';
    x int2;

    current_person_geom geometry;
    center_geometry geometry;

    i integer := 0;

  BEGIN

    EXECUTE 'DELETE FROM  vicinity;';

    SELECT count(*) from palms_output_geom INTO k;
    SELECT count(*) FROM timesteps INTO n_timesteps;
    SELECT count(*) FROM person_identifiers INTO n_persons;

    RAISE NOTICE '% timesteps.', n_timesteps;
    RAISE NOTICE '% persons.', n_persons;

    FOR t IN SELECT * FROM timesteps LOOP

      RAISE NOTICE '% / % !', i, n_timesteps;

      FOR person_identifier IN SELECT identifier FROM person_identifiers LOOP

        SELECT geom from palms_output_geom
        WHERE identifier=person_identifier AND palms_datetime=t.palms_datetime
        INTO current_person_geom;

        FOR r1 IN

        SELECT * FROM palms_output_geom

        WHERE
          palms_datetime = t.palms_datetime
          AND
          ST_Distance_Sphere(geom , current_person_geom) < getBufferSize()
          AND identifier != person_identifier

        LOOP

          if r1.identifier != person_identifier THEN

            center_geometry := ST_Line_Interpolate_Point(ST_MakeLine(current_person_geom, r1.geom), 0.5);
            distance := ST_Distance(current_person_geom, r1.geom);

            BEGIN

              SELECT count(*) FROM vicinity WHERE person1=r1.identifier AND person2=person_identifier AND palms_datetime=t.palms_datetime INTO x;

              IF x=0 THEN

                EXECUTE 'INSERT INTO vicinity (geom, person1, person2, distance, palms_datetime) VALUES ('
                        || q || center_geometry::varchar || q || ','
                        || person_identifier || ','
                        || r1.identifier || ','
                        || distance || ',' || q
                        || t.palms_datetime || q || ');';

              END IF;

            END;
          END IF;

        END LOOP;
      END LOOP;

      i := i + 1;

    END LOOP;

    RAISE NOTICE 'FINISHED !';

    RETURN 'create_vicinity() finished!';

  END;$BODY$
LANGUAGE plpgsql VOLATILE
COST 1;


-- --
-- 9_remove_doublettes.sql
-- --
CREATE OR REPLACE FUNCTION remove_doublettes()
  RETURNS varchar AS
  $BODY$DECLARE

    r1 vicinity%rowtype;


  BEGIN

    FOR r1 IN SELECT * FROM vicinity LOOP

      -- RAISE NOTICE '%', r1;

      DELETE FROM vicinity WHERE person1=r1.person2 AND person2=r1.person1 and palms_datetime=r1.palms_datetime;

    END LOOP;

    RETURN 'sexy!';

  END;$BODY$
LANGUAGE plpgsql VOLATILE
COST 1;

-- --
-- 10_func_create_meetings.sql
-- --
CREATE OR REPLACE FUNCTION create_meetings()
  RETURNS varchar AS
  $BODY$DECLARE

    r1 vicinity%rowtype;
    r2 vicinity%rowtype;
    t timesteps%rowtype;

    p1 person_identifiers%rowtype;
    p2 person_identifiers%rowtype;

    gg geometry[];
    g geometry;

    k bigint;
    n bigint;

    q varchar := '''';

    status smallint  := 0;
    c smallint;

    begin_time timestamp without time zone;

    polyline geometry;

  BEGIN

    EXECUTE 'DELETE FROM  meeting;';

    RAISE NOTICE 'Starting.';

    SELECT count(*) from vicinity INTO k;

    RAISE NOTICE '%', k;

    FOR p1 IN SELECT * FROM person_identifiers LOOP
      FOR p2 IN SELECT * FROM person_identifiers LOOP

        RAISE NOTICE '% <-> %', p1.identifier, p2.identifier;

        FOR t IN SELECT * FROM timesteps LOOP

          SELECT count(*) FROM vicinity
          WHERE palms_datetime = t.palms_datetime
                AND person1 = p1.identifier
                AND person2 = p2.identifier
          INTO c;

          IF c = 1 AND status = 0 THEN
            SELECT geom
            FROM vicinity
            WHERE palms_datetime=t.palms_datetime
                  AND person1=p1.identifier
                  AND person2=p2.identifier INTO g;
            begin_time := t.palms_datetime;
            status = 1;             -- we are now inside a meeting
            gg = array[]::geometry[];
            gg = array_append(gg, g);
          END IF;

          IF c = 1 AND status = 1 THEN
            SELECT geom
            FROM vicinity
            WHERE palms_datetime=t.palms_datetime
                  AND person1=p1.identifier
                  AND person2=p2.identifier INTO g;
            gg = array_append(gg, g);
          END IF;

          IF c = 0 AND status = 1 THEN
            polyline = ST_Makeline(gg);
            status = 0;
            EXECUTE 'INSERT INTO meeting (geom, person1, person2, begin_time, end_time, duration) VALUES ('
                    || q || polyline::varchar || q || ','
                    || p1.identifier || ','
                    || p2.identifier || ',' || q
                    || begin_time || q || ',' || q
                    || t.palms_datetime || q || ',' || q
                    || t.palms_datetime - begin_time || q || ');';
          END IF;

        END LOOP;
      END LOOP;
    END LOOP;

    RAISE NOTICE 'FINISHED !';

    RETURN 'create_meetings() finished !';

  END;$BODY$
LANGUAGE plpgsql VOLATILE
COST 1;

-- --
-- 11_add_indexes.sql
-- --
DROP INDEX IF EXISTS idx_palms_vicinity_person_one;
CREATE INDEX  "idx_palms_vicinity_person_one" ON vicinity USING BTREE (person1);

DROP INDEX IF EXISTS idx_palms_vicinity_person_two;
CREATE INDEX  "idx_palms_vicinity_person_two" ON vicinity USING BTREE (person2);

DROP INDEX IF EXISTS idx_palms_vicinity_palms_datetime;
CREATE INDEX  "idx_palms_vicinity_palms_datetime" ON vicinity USING BTREE (palms_datetime);

DROP INDEX IF EXISTS idx_person_identifiers;
CREATE INDEX  "idx_person_identifiers" ON person_identifiers USING BTREE (identifier);

DROP INDEX IF EXISTS idx_timesteps;
CREATE INDEX  "idx_timesteps" ON timesteps USING BTREE (palms_datetime);

-- --
-- 12_table_meeting.sql
-- --

DROP TABLE IF EXISTS meeting;
DROP SEQUENCE IF EXISTS meeting_id_seq;
CREATE SEQUENCE meeting_id_seq;

DROP TABLE IF EXISTS meeting CASCADE;
CREATE TABLE meeting
(
  id serial primary key,
  geom geometry,
  person1 int8,
  person2 int8,
  begin_time timestamp without time zone,
  end_time timestamp without time zone,
  duration interval
);

COMMIT;

-- --
-- 13_create_data.sql
-- --

SELECT * FROM create_vicinity();
COMMIT;
--SELECT * FROM remove_doublettes();
SELECT * FROM create_meetings();
