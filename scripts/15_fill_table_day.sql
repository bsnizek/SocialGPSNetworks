
CREATE OR REPLACE FUNCTION fill_table(d DATE)
  RETURNS varchar AS
  $BODY$DECLARE

    p1 int8;
    p2 int8;
    dur time without time zone;
    s1 varchar;

    flds varchar;
    vls varchar;
    xx varchar;

    q varchar := '''';

  BEGIN

    FOR p1 IN SELECT identifier FROM person_identifiers LOOP

      flds := '"identifier"' || ',';
      vls := q || 'p' || p1 || q || ',';

      FOR p2 IN SELECT identifier FROM person_identifiers LOOP

        flds := flds || '"' || 'p' || p2 || '"' || ',';

        vls := vls || isWithinTime(d, p1, p2) || ',';

        -- INSERT INTO day (IDENTIFIER, p2.1, p2.2, p2.3) VALUES (p1, dur1, dur2, dur3);

      END LOOP;

      flds := '(' || left(flds, length(flds)-1) || ')';
      vls := '(' || left(vls, length(vls)-1) || ')';

      xx := 'INSERT INTO day ' || flds || ' VALUES ' || vls || ';';

      EXECUTE xx;

    END LOOP;

    RETURN 'fill_table(' || d::varchar || ') finished!';

  END;$BODY$
LANGUAGE plpgsql VOLATILE
COST 1;