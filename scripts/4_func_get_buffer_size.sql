
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


