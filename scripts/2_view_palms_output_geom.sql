
-- palms-output-geog : palms_output plus geography
DROP MATERIALIZED VIEW IF EXISTS palms_output_geom CASCADE;

DROP SEQUENCE IF EXISTS palms_output_geom_uid_seq;
CREATE SEQUENCE palms_output_geom_uid_seq START 1;

CREATE MATERIALIZED VIEW palms_output_geom AS
  SELECT
    -- getUniqueTripId(identifier, tripnumber, palms_datetime::date) AS unique_trip_id,

    nextval('palms_output_geom_uid_seq') AS uid,

    (identifier || '-' || tripnumber || '-' || to_char(palms_datetime::date,'YYYYMMDD')) AS unique_trip_id,

    ST_Transform(
        ST_SetSRID(
            new_ST_Makepoint(palms_output.lon,
                             palms_output.lat), 4326),
        4326) AS geom, --25832

    ST_AsText(ST_Transform(
        ST_SetSRID(
            new_ST_Makepoint(palms_output.lon,
                             palms_output.lat), 4326),
        4326)) AS geom_text,

    palms_datetime AS dte,
    *
  FROM palms_output;


DROP INDEX IF EXISTS palms_output_geom_idx;
CREATE UNIQUE INDEX palms_output_geom_idx
  ON palms_output_geom (uid);

DROP INDEX IF EXISTS gidx_palms_output_geom;
CREATE INDEX gidx_palms_output_geom ON palms_output_geom USING GIST (geom);

DROP INDEX IF EXISTS idx_palms_output_identifier;
CREATE INDEX  "idx_palms_output_identifier" ON palms_output_geom USING BTREE (identifier);

DROP INDEX IF EXISTS idx_palms_output_unique_trip_id;
CREATE INDEX  "idx_palms_output_unique_trip_id" ON palms_output_geom USING BTREE (unique_trip_id);
