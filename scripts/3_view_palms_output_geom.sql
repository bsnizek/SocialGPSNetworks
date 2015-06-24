
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
