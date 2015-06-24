CREATE OR REPLACE FUNCTION time_in_date(t timestamp without time zone, d DATE)
  RETURNS boolean AS
  $BODY$DECLARE

  BEGIN

  RETURN t::date = d;

  END;$BODY$
LANGUAGE plpgsql VOLATILE
COST 1;


CREATE OR REPLACE FUNCTION isWithinTime(d date, p1 int8, p2 int8)
  RETURNS boolean AS
  $BODY$DECLARE

    dur time;
    r boolean;

  BEGIN

    SELECT sum(duration)
    FROM meeting WHERE
      time_in_date(begin_time, d) AND
      person1=p1 AND person2=p2
    INTO dur;

    IF DUR > getTimeTreshold() THEN
      r := true;
    ELSE
      r:= false;
    END IF;

    RETURN r;

  END;$BODY$
LANGUAGE plpgsql VOLATILE
COST 1;


