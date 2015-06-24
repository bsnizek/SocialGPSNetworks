
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
