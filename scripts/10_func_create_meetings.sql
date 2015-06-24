
-- --
-- 10_func_create_meetings.sql
-- --
CREATE OR REPLACE FUNCTION create_meetings()
  RETURNS varchar AS
  $BODY$DECLARE

    r1 vicinity%rowtype;
    r2 vicinity%rowtype;
    t timesteps%rowtype;

    p1 person_identifiers%rowtype;
    p2 person_identifiers%rowtype;

    gg geometry[];
    g geometry;

    k bigint;
    n bigint;

    q varchar := '''';

    status smallint  := 0;
    c smallint;

    begin_time timestamp without time zone;

    polyline geometry;

  BEGIN

    EXECUTE 'DELETE FROM  meeting;';

    RAISE NOTICE 'Starting.';

    SELECT count(*) from vicinity INTO k;

    RAISE NOTICE '%', k;

    FOR p1 IN SELECT * FROM person_identifiers LOOP
      FOR p2 IN SELECT * FROM person_identifiers LOOP

        RAISE NOTICE '% <-> %', p1.identifier, p2.identifier;

        FOR t IN SELECT * FROM timesteps LOOP

          SELECT count(*) FROM vicinity
          WHERE palms_datetime = t.palms_datetime
                AND person1 = p1.identifier
                AND person2 = p2.identifier
          INTO c;

          IF c = 1 AND status = 0 THEN
            SELECT geom
            FROM vicinity
            WHERE palms_datetime=t.palms_datetime
                  AND person1=p1.identifier
                  AND person2=p2.identifier INTO g;
            begin_time := t.palms_datetime;
            status = 1;             -- we are now inside a meeting
            gg = array[]::geometry[];
            gg = array_append(gg, g);
          END IF;

          IF c = 1 AND status = 1 THEN
            SELECT geom
            FROM vicinity
            WHERE palms_datetime=t.palms_datetime
                  AND person1=p1.identifier
                  AND person2=p2.identifier INTO g;
            gg = array_append(gg, g);
          END IF;

          IF c = 0 AND status = 1 THEN
            polyline = ST_Makeline(gg);
            status = 0;
            EXECUTE 'INSERT INTO meeting (geom, person1, person2, begin_time, end_time, duration) VALUES ('
                    || q || polyline::varchar || q || ','
                    || p1.identifier || ','
                    || p2.identifier || ',' || q
                    || begin_time || q || ',' || q
                    || t.palms_datetime || q || ',' || q
                    || t.palms_datetime - begin_time || q || ');';
          END IF;

        END LOOP;
      END LOOP;
    END LOOP;

    RAISE NOTICE 'FINISHED !';

    RETURN 'create_meetings() finished !';

  END;$BODY$
LANGUAGE plpgsql VOLATILE
COST 1;
