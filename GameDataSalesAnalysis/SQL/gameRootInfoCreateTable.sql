create table gamesalesinfo
(
    "Name"             varchar not null,
    "Platform"         varchar not null,
    "Year_of_Release"  date,
    "Genre"            varchar,
    "Publisher"        varchar,
    "NA_Sales"         numeric,
    "EU_Sales"         numeric,
    "JP_Sales"         numeric,
    "Other_Sales"      numeric,
    "Global_Sales"     numeric,
    "Critic_Score"     integer,
    "Critic_Count"     integer,
    "User_Score"       numeric,
    "User_Count"       integer,
    "Developer"        varchar,
    "Rating"           varchar,
    "Other_Developers" varchar,
    primary key ("Name", "Platform")
);

alter table gamesalesinfo
    owner to postgres;


