-- --
-- 10_func_create_meetings.sql
-- --
CREATE OR REPLACE FUNCTION create_day_table()
  RETURNS varchar AS
  $BODY$DECLARE

    s varchar;
    i varchar;

  BEGIN

    EXECUTE 'DROP TABLE IF EXISTS day CASCADE;';

    s := 'CREATE TABLE day (identifier varchar,';

    FOR i IN select identifier FROM person_identifiers LOOP

      s := s || 'p' || i || ' boolean,';

    END LOOP;

    s := left(s, length(s)-1);

    s := s  || ');';

    EXECUTE s;

    RETURN 'create_day_table() finished!';

  END;$BODY$
LANGUAGE plpgsql VOLATILE
COST 1;
