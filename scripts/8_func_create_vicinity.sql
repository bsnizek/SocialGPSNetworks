
-- --
-- 8_func_create_vicinity.sql
-- --
CREATE OR REPLACE FUNCTION create_vicinity()
  RETURNS varchar AS
  $BODY$DECLARE

    r1 palms_output_geom%rowtype;
    t timesteps%rowtype;

    person_identifiers int8[];

    distance float;
    ins varchar;

    k bigint;
    n_timesteps bigint;
    n_persons bigint;

    p1 varchar;
    p2 varchar;

    person_identifier int8;

    q varchar := '''';
    x int2;

    current_person_geom geometry;
    center_geometry geometry;

    i integer := 0;

  BEGIN

    EXECUTE 'DELETE FROM  vicinity;';

    SELECT count(*) from palms_output_geom INTO k;
    SELECT count(*) FROM timesteps INTO n_timesteps;
    SELECT count(*) FROM person_identifiers INTO n_persons;

    RAISE NOTICE '% timesteps.', n_timesteps;
    RAISE NOTICE '% persons.', n_persons;

    FOR t IN SELECT * FROM timesteps LOOP

      RAISE NOTICE '% / % !', i, n_timesteps;

      FOR person_identifier IN SELECT identifier FROM person_identifiers LOOP

        SELECT geom from palms_output_geom
        WHERE identifier=person_identifier AND palms_datetime=t.palms_datetime
        INTO current_person_geom;

        FOR r1 IN

        SELECT * FROM palms_output_geom

        WHERE
          palms_datetime = t.palms_datetime
          AND
          ST_Distance_Sphere(geom , current_person_geom) < getBufferSize()
          AND identifier != person_identifier

        LOOP

          if r1.identifier != person_identifier THEN

            center_geometry := ST_Line_Interpolate_Point(ST_MakeLine(current_person_geom, r1.geom), 0.5);
            distance := ST_Distance(current_person_geom, r1.geom);

            BEGIN

              SELECT count(*) FROM vicinity WHERE person1=r1.identifier AND person2=person_identifier AND palms_datetime=t.palms_datetime INTO x;

              IF x=0 THEN

                EXECUTE 'INSERT INTO vicinity (geom, person1, person2, distance, palms_datetime) VALUES ('
                        || q || center_geometry::varchar || q || ','
                        || person_identifier || ','
                        || r1.identifier || ','
                        || distance || ',' || q
                        || t.palms_datetime || q || ');';

              END IF;

            END;
          END IF;

        END LOOP;
      END LOOP;

      i := i + 1;

    END LOOP;

    RAISE NOTICE 'FINISHED !';

    RETURN 'create_vicinity() finished!';

  END;$BODY$
LANGUAGE plpgsql VOLATILE
COST 1;

