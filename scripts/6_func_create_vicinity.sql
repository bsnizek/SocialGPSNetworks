CREATE OR REPLACE FUNCTION create_vicinity()
  RETURNS varchar AS
  $BODY$DECLARE

    r1 palms_output_geom%rowtype;
    r2 palms_output_geom%rowtype;
    distance float;
    ins varchar;

    k bigint;
    n bigint;

    q varchar := '''';

  BEGIN

    EXECUTE 'DELETE FROM  vicinity;';

    SELECT count(*) from palms_output_geom INTO k;
    n := k*k;

    RAISE NOTICE '%', n;

    FOR r1 IN SELECT * FROM palms_output_geom LIMIT 10 LOOP
      FOR r2 IN SELECT * FROM palms_output_geom LIMIT 10 LOOP
        distance = ST_Distance(r1.geom, r2.geom);
        IF distance < 10.0 THEN
          BEGIN
            EXECUTE 'INSERT INTO vicinity (person1, person2, distance, palms_datetime) VALUES ('
                  || r1.identifier || ','
                  || r2.identifier || ','
                  || distance || ',' || q
                  || r1.palms_datetime || q || ');';
          END;
        END IF;
      END LOOP;
    END LOOP;

    RAISE NOTICE 'FINISHED !';

    RETURN 'sexy!';

  END;$BODY$
LANGUAGE plpgsql VOLATILE
COST 1;

-- SELECT * FROM create_vicinity();
