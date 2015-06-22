CREATE OR REPLACE FUNCTION create_vicinity()
  RETURNS varchar AS
  $BODY$DECLARE

    r1 palms_output_geom%rowtype;
    r2 palms_output_geom%rowtype;
    t timesteps%rowtype;

    person_identifiers varchar[];

    distance float;
    ins varchar;

    k bigint;
    n bigint;
    n_timesteps bigint;
    n_persons bigint;

    p1 varchar;
    p2 varchar;

    q varchar := '''';

  BEGIN

    EXECUTE 'DELETE FROM  vicinity;';

    SELECT count(*) from palms_output_geom INTO k;
    SELECT count(*) FROM timesteps INTO n_timesteps;
    SELECT count(*) FROM person_identifiers INTO n_persons;
    --     SELECT identifier FROM person_identifiers INTO person_identifiers; TODO !!
    n := k*k;

    RAISE NOTICE '% GPS points', n;
    RAISE NOTICE '% timesteps.', n_timesteps;
    RAISE NOTICE '% persons.', n_persons;

    FOR t IN SELECT * FROM timesteps LOOP

      FOR p1 IN SELECT identifier FROM person_identifiers LOOP
        FOR p2 IN SELECT identifier FROM person_identifiers LOOP

          FOR r1 IN SELECT * FROM palms_output_geom WHERE IDENTIFIER=p1 AND palms_datetime=t.palms_datetime LOOP
            FOR r2 IN SELECT * FROM palms_output_geom WHERE IDENTIFIER=p2 AND palms_datetime=t.palms_datetime LOOP
              IF (r1 != r2) THEN

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

              END IF;

            END LOOP;
          END LOOP;

        END LOOP;
      END LOOP;
    END LOOP;


    RAISE NOTICE 'FINISHED !';

    RETURN 'sexy!';

  END;$BODY$
LANGUAGE plpgsql VOLATILE
COST 1;

-- SELECT * FROM create_vicinity();
