
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
