
-- --
-- 2_table_config.sql
-- --
DROP TABLE IF EXISTS config;
DROP SEQUENCE IF EXISTS config_id_seq;
CREATE SEQUENCE config_id_seq;

DROP TABLE IF EXISTS config CASCADE;
CREATE TABLE config
(
  id int8 NOT NULL DEFAULT nextval('config_id_seq'),
  buffer_size float,
  time_threshold time,
  base_path varchar,
  source_file varchar
);

INSERT INTO config (buffer_size, time_threshold, source_file, base_path)
VALUES (30.0,
        '00:10:00',
        'palms_output_social_network_kild2012_test.csv',
        '/Users/besn/Projects/SocialGPSNetworks/');
