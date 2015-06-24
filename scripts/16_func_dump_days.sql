CREATE OR REPLACE FUNCTION dumpDays()
  RETURNS varchar AS
  $BODY$DECLARE

    s varchar;
    i varchar;
    d date;
    x varchar;
    q varchar := '''';

  BEGIN

    FOR d IN SELECT palms_datetime FROM days LOOP

      PERFORM * from create_day_table();
      PERFORM * from fill_table(d);

      x :=  'COPY day TO ' ||
            q ||
            '/Users/besn/Projects/SocialGPSNetworks/' ||
            d::varchar || '.csv' ||
            q ||
            ' DELIMITER ' ||
            q ||
            ',' ||
            q ||
            ' CSV HEADER;';

      RAISE NOTICE '%', x;
      EXECUTE x;

    END LOOP;

    RETURN 'dumpDays finished.';

  END;$BODY$
LANGUAGE plpgsql VOLATILE
COST 1;