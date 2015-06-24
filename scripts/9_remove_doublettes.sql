
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
