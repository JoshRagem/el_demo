\c whc

CREATE TABLE IF NOT EXISTS "whcsites"(
"uid" integer PRIMARY KEY,
"id" integer,
"name_en" TEXT,
"name_fr" TEXT,
"short_description_en" TEXT,
"short_description_fr" TEXT,
"justification_en" TEXT,
"justification_fr" TEXT,
"date_inscribed" TEXT,
"danger" TEXT,
"danger_list" TEXT,
"longitude" TEXT,
"latitude" TEXT,
"states_name_en" TEXT,
"states_name_fr" TEXT,
"region_en" TEXT,
"region_fr" TEXT
);
 INSERT INTO whcsites SELECT unique_number as uid, id_no as id, name_en, name_fr, short_description_en,
                             short_description_fr, justification_en, justification_fr, date_inscribed,
                             danger, danger_list, longitude, latitude, states_name_en, states_name_fr,
                             region_en, region_fr
                      FROM whcsites_raw;