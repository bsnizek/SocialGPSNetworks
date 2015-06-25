
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


