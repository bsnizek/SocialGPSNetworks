
-- --
-- 5_table_vicinity.sql
-- --
DROP TABLE IF EXISTS vicinity;
DROP SEQUENCE IF EXISTS vicinity_id_seq;
CREATE SEQUENCE vicinity_id_seq;

DROP TABLE IF EXISTS vicinity CASCADE;
CREATE TABLE vicinity
(
  id serial primary key,
  geom geometry,
  person1 int8,
  person2 int8,
  palms_datetime timestamp without time zone,
  distance float
);

COMMIT;
