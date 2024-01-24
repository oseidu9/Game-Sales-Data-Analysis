create table gameinfo
(
    "Name"            varchar not null,
    "Platform"        varchar not null,
    "Year_of_Release" integer,
    "Genre"           varchar,
    "Publisher"       varchar,
    "Developer"       varchar,
    "Rating"          varchar,
    primary key ("Name", "Platform")
);

alter table gameinfo
    owner to postgres;

create table criticsinfo
(
    "Name"         varchar,
    "Platform"     varchar,
    "Critic_Score" integer,
    "Critic_Count" integer,
    "User_Score"   numeric,
    "User_Count"   integer,
    constraint criticsinfo_gameinfo_name_platform_fk
        foreign key ("Name", "Platform") references gameinfo
);

alter table criticsinfo
    owner to postgres;

create table salesinfo
(
    "Name"        varchar,
    "Platform"    varchar,
    "NA_Sales"    numeric,
    "EU_Sales"    numeric,
    "JP_Sales"    numeric,
    "Other_Sales" numeric,
    constraint salesinfo_gameinfo_name_platform_fk
        foreign key ("Name", "Platform") references gameinfo
);

alter table salesinfo
    owner to postgres;

create view numberonegameperregion(region, "Name", "Platform", salespermillion) as
WITH regions AS (SELECT columns.column_name,
                        CASE
                            WHEN columns.column_name::name = 'NA_Sales'::name THEN 'North America'::text
                            WHEN columns.column_name::name = 'EU_Sales'::name THEN 'Europe'::text
                            WHEN columns.column_name::name = 'JP_Sales'::name THEN 'Japan'::text
                            WHEN columns.column_name::name = 'Other_Sales'::name THEN 'Other'::text
                            ELSE NULL::text
                            END AS region
                 FROM information_schema.columns
                 WHERE columns.table_name::name = 'salesinfo'::name
                   AND (columns.column_name::name = ANY
                        (ARRAY ['NA_Sales'::name, 'EU_Sales'::name, 'JP_Sales'::name, 'Other_Sales'::name]))),
     gamesalesrankedperregion AS (SELECT salesinfo."Name",
                                         salesinfo."Platform",
                                         dense_rank() OVER (ORDER BY salesinfo."EU_Sales" DESC)    AS eusalesrank,
                                         salesinfo."EU_Sales",
                                         dense_rank() OVER (ORDER BY salesinfo."NA_Sales" DESC)    AS nasalesrank,
                                         salesinfo."NA_Sales",
                                         dense_rank() OVER (ORDER BY salesinfo."Other_Sales" DESC) AS othersalesrank,
                                         salesinfo."Other_Sales",
                                         dense_rank() OVER (ORDER BY salesinfo."JP_Sales" DESC)    AS jpsalesrank,
                                         salesinfo."JP_Sales"
                                  FROM salesinfo)
SELECT regions.region,
       gamesalesrankedperregion."Name",
       gamesalesrankedperregion."Platform",
       CASE
           WHEN regions.region = 'North America'::text THEN gamesalesrankedperregion."NA_Sales"
           WHEN regions.region = 'Europe'::text THEN gamesalesrankedperregion."EU_Sales"
           WHEN regions.region = 'Japan'::text THEN gamesalesrankedperregion."JP_Sales"
           WHEN regions.region = 'Other'::text THEN gamesalesrankedperregion."Other_Sales"
           ELSE NULL::numeric
           END AS salespermillion
FROM regions,
     gamesalesrankedperregion
WHERE CASE
          WHEN regions.region = 'North America'::text THEN gamesalesrankedperregion.nasalesrank = 1
          WHEN regions.region = 'Europe'::text THEN gamesalesrankedperregion.eusalesrank = 1
          WHEN regions.region = 'Japan'::text THEN gamesalesrankedperregion.jpsalesrank = 1
          WHEN regions.region = 'Other'::text THEN gamesalesrankedperregion.othersalesrank = 1
          ELSE NULL::boolean
          END;

alter table numberonegameperregion
    owner to postgres;


