
-- --
-- makepoint
-- --

CREATE OR REPLACE FUNCTION new_ST_Makepoint(lon float8, lat float8)

  RETURNS Geometry AS
  $BODY$DECLARE

  BEGIN

    IF lon = -180 OR lat = -180 THEN
      RETURN ST_Makepoint(0, 0);
    ELSE

      RETURN ST_Makepoint(lon, lat);

    END IF;

  END
  $BODY$ LANGUAGE 'plpgsql'
COST 100;