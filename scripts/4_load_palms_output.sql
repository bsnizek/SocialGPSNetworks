

CREATE OR REPLACE FUNCTION loadPalmsFile()
  RETURNS varchar AS
  $BODY$

  DECLARE

  x varchar;
  q varchar := '''';

  BEGIN

    x := 'COPY palms_output' ||
    ' FROM ' || q || getBasePath() || 'input/' || getSourceFile() || q ||
    ' WITH (FORMAT csv, DELIMITER ' || q || ',' || q || ', HEADER);';

    EXECUTE x;


    RETURN 'loadPalmsFile() finished';

  END;$BODY$
LANGUAGE plpgsql VOLATILE
COST 100;

SELECT * FROM loadPalmsFile();