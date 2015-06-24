
-- --
-- 12_table_meeting.sql
-- --

DROP TABLE IF EXISTS meeting;
DROP SEQUENCE IF EXISTS meeting_id_seq;
CREATE SEQUENCE meeting_id_seq;

DROP TABLE IF EXISTS meeting CASCADE;
CREATE TABLE meeting
(
  id serial primary key,
  geom geometry,
  person1 int8,
  person2 int8,
  begin_time timestamp without time zone,
  end_time timestamp without time zone,
  duration interval
);

COMMIT;

