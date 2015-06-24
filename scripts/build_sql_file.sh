#!/usr/bin/env bash

rm social_gps_networks.sql

cat 1_import_palms_file.sql                                 >> social_gps_networks.sql
cat 2_table_config.sql                                      >> social_gps_networks.sql
cat 3_view_palms_output_geom.sql                            >> social_gps_networks.sql
cat 4_func_get_buffer_size.sql                              >> social_gps_networks.sql
cat 5_table_vicinity.sql                                    >> social_gps_networks.sql
cat 6_view_timesteps.sql                                    >> social_gps_networks.sql
cat 7_view_person_identifiers.sql                           >> social_gps_networks.sql
cat 8_func_create_vicinity.sql                              >> social_gps_networks.sql
cat 9_remove_doublettes.sql                                 >> social_gps_networks.sql
cat 10_func_create_meetings.sql                             >> social_gps_networks.sql
cat 11_add_indexes.sql                                      >> social_gps_networks.sql
cat 12_table_meeting.sql                                    >> social_gps_networks.sql
cat 13_create_data.sql                                      >> social_gps_networks.sql