
-- --
-- 11_add_indexes.sql
-- --
DROP INDEX IF EXISTS idx_palms_vicinity_person_one;
CREATE INDEX  "idx_palms_vicinity_person_one" ON vicinity USING BTREE (person1);

DROP INDEX IF EXISTS idx_palms_vicinity_person_two;
CREATE INDEX  "idx_palms_vicinity_person_two" ON vicinity USING BTREE (person2);

DROP INDEX IF EXISTS idx_palms_vicinity_palms_datetime;
CREATE INDEX  "idx_palms_vicinity_palms_datetime" ON vicinity USING BTREE (palms_datetime);

DROP INDEX IF EXISTS idx_person_identifiers;
CREATE INDEX  "idx_person_identifiers" ON person_identifiers USING BTREE (identifier);

DROP INDEX IF EXISTS idx_timesteps;
CREATE INDEX  "idx_timesteps" ON timesteps USING BTREE (palms_datetime);
