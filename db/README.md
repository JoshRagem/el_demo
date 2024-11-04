# WHC Sites in Postgres

The whc sites were provided in a `.csv` file, so I used sqlite to convert that information to a `.sql` file. The full information is loaded into a `whcsites_raw` table, from which I copy the subset of columns I'm interested in handling

These `.sql` files work both in the `/docker-entrypoint-initdb.d` directory of the official postgres docker image and as files executed by `psql` connected to rds.

### Table Schema

```
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
```

For the simple feature of listing and showing whc sites, the straightforward primary key index is sufficient. The `_en` and `_fr` fields are preserved in this smaller table because I intended to use the `Accept-Language` header to localize the api response to those two languages (with the other languages following after).