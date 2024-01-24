/*retrieve gameinfo table*/
select * from gameinfo order by "Name";

/*retrieve criticsinfo table*/
select * from criticsinfo order by  "Name";

/*retrieve data from sales table, ordered by sum of sales, then name*/
select "Name", "Platform", "NA_Sales", "EU_Sales", "JP_Sales", "Other_Sales" from salesinfo where "Name" = 'Diablo'
order by ("NA_Sales" + "EU_Sales" + "JP_Sales" + "Other_Sales") desc, "Name" asc;

/*what percentage of sales are from EU per game 2dp + concat percentage (ignore games with sales sum of 0)
  make sure to order by the NUMBER of the percentage, not the CONCATENATION, otherwise it will be ordered as if its a string*/
select "Name", "Platform", concat(round(100*("EU_Sales"/("NA_Sales"+"EU_Sales"+"JP_Sales"+"Other_Sales")), 2), '%') as EUSalesPercentage
from salesinfo where ("NA_Sales"+"EU_Sales"+"JP_Sales"+"Other_Sales")!=0 order by "EU_Sales"/("NA_Sales"+"EU_Sales"+"JP_Sales"+"Other_Sales") desc, "Name" asc;

select * from salesinfo where "Name"='15 Days';

/*what percentage of sales are from EU FOR PC GAMES 2dp + concat percentage (ignore games with sales sum of 0)
  make sure to order by the NUMBER of the percentage, not the CONCATENATION, otherwise it will be ordered as if its a string*/
select "Name", "Platform", concat(round(100*("EU_Sales"/("NA_Sales"+"EU_Sales"+"JP_Sales"+"Other_Sales")), 2), '%') as EUSalesPercentage
from salesinfo where ("NA_Sales"+"EU_Sales"+"JP_Sales"+"Other_Sales")!=0 and "Platform"='PC' order by "EU_Sales"/("NA_Sales"+"EU_Sales"+"JP_Sales"+"Other_Sales") desc, "Name" asc;

/*what percentage of sales are from EU FOR Playstation KH games? (any playstation console) 2dp + concat percentage (ignore games with sales sum of 0)
  make sure to order by the NUMBER of the percentage, not the CONCATENATION, otherwise it will be ordered as if its a string*/
select "Name", "Platform", concat(round(100*("EU_Sales"/("NA_Sales"+"EU_Sales"+"JP_Sales"+"Other_Sales")), 2), '%') as EUSalesPercentage
from salesinfo where ("NA_Sales"+"EU_Sales"+"JP_Sales"+"Other_Sales")!=0 and "Name" like 'Kingdom Hearts%' and "Platform" like 'PS%'
order by "EU_Sales"/("NA_Sales"+"EU_Sales"+"JP_Sales"+"Other_Sales") desc, "Name" asc;

/*which game has the highest number of EU sales*/
select t."Name", t."Platform", t."EU_Sales" from salesinfo t where
t."EU_Sales" = (select max("EU_Sales") from salesinfo);

/*which games have the highest EU sales percentage? (basically supposedly 100% eu sales since that is the highest EU percentage sale)*/
select "Name", "Platform", concat(round(100*("EU_Sales"/("NA_Sales"+"EU_Sales"+"JP_Sales"+"Other_Sales")), 2), '%') as EUSalesPercentage
from salesinfo where ("NA_Sales"+"EU_Sales"+"JP_Sales"+"Other_Sales")!=0 and "EU_Sales"/("NA_Sales"+"EU_Sales"+"JP_Sales"+"Other_Sales") in
             (select max("EU_Sales"/("NA_Sales"+"EU_Sales"+"JP_Sales"+"Other_Sales")) from salesinfo where ("NA_Sales"+"EU_Sales"+"JP_Sales"+"Other_Sales")!=0)
               order by "EU_Sales"/("NA_Sales"+"EU_Sales"+"JP_Sales"+"Other_Sales") desc, "Name" asc;

/*for each game, how many sales in each region (and globally) rank.*/
  select "Name", dense_rank() over (order by "EU_Sales" desc) as EUSalesRank, dense_rank() over (order by "NA_Sales" desc) as NASalesRank,
         dense_rank() over (order by "Other_Sales" desc) as OtherSalesRank, dense_rank() over (order by "JP_Sales" desc) as JPSalesRank, dense_rank() over (order by "JP_Sales" + "EU_Sales" + "NA_Sales" + "Other_Sales" desc) as GlobalSalesRank
  from salesinfo;


/*count total number of all games sold in EU per console*/
select "Platform", sum("EU_Sales") from salesinfo
group by "Platform" order by sum("EU_Sales") desc;



  /*get best selling game in each region. use CTE*/

  /*first, create column of regions*/
with Regions as (select column_name, CASE
    when column_name = 'NA_Sales' then 'North America'
    when column_name = 'EU_Sales' then 'Europe'
    when column_name = 'JP_Sales' then 'Japan'
    when column_name = 'Other_Sales' then 'Other'
   end
    as Region
from information_schema.columns
where table_name = 'salesinfo' and column_name in ('NA_Sales', 'EU_Sales', 'JP_Sales', 'Other_Sales')),

    /*second, get sales ranking for each game in each region*/
    gameSalesRankedPerRegion as (select "Name", dense_rank() over (order by "EU_Sales" desc) as EUSalesRank, dense_rank() over (order by "NA_Sales" desc) as NASalesRank,
         dense_rank() over (order by "Other_Sales" desc) as OtherSalesRank, dense_rank() over (order by "JP_Sales" desc) as JPSalesRank from salesinfo)

/*third, run a query to get the number 1 ranked selling game for each region.*/
select Regions.Region, gameSalesRankedPerRegion."Name" from Regions, gameSalesRankedPerRegion where
  case
      when Regions.Region = 'North America' then gameSalesRankedPerRegion.NASalesRank = 1
      when Regions.Region = 'Europe' then gameSalesRankedPerRegion.EUSalesRank = 1
      when Regions.Region = 'Japan' then gameSalesRankedPerRegion.JPSalesRank = 1
      when Regions.Region = 'Other' then gameSalesRankedPerRegion.OtherSalesRank = 1
  end;

/*highest selling EU games per console*/
select t."Name", t."Platform", t."EU_Sales" from salesinfo t where t."EU_Sales" = (select max(s."EU_Sales") from salesinfo s where t."Platform"=s."Platform") order by "Platform";

/*join salesinfo with gameinfo*/
select distinct salesinfo."Name" from salesinfo left join gameinfo on salesinfo."Name" = gameinfo."Name" and salesinfo."Platform" = gameinfo."Platform" order by salesinfo."Name";

/*count the number of games released on 2006 per console (if applicable)
  (for each console, count the number of game entries released for that console in 2006)
  (should work but has 1 more than expected due to duplicate entry for Sonic the Hedgehog in salesinfo table.)*/
select distinct gameinfo."Platform", count(*) over (partition by salesinfo."Platform") from gameinfo left join salesinfo on salesinfo."Name" = gameinfo."Name" and salesinfo."Platform" = gameinfo."Platform"
where gameinfo."Year_of_Release" = 2006;

select * from gameinfo where "Year_of_Release"=2006 and "Platform"='PS3' order by "Name";

/*testing view creation (use number one best selling game per region query as example)*/
create view NumberOneGamePerRegion as (  /*first, create column of regions*/
with Regions as (select column_name, CASE
    when column_name = 'NA_Sales' then 'North America'
    when column_name = 'EU_Sales' then 'Europe'
    when column_name = 'JP_Sales' then 'Japan'
    when column_name = 'Other_Sales' then 'Other'
   end
    as Region
from information_schema.columns
where table_name = 'salesinfo' and column_name in ('NA_Sales', 'EU_Sales', 'JP_Sales', 'Other_Sales')),

    /*second, get sales ranking for each game in each region*/
    gameSalesRankedPerRegion as (select "Name", "Platform", dense_rank() over (order by "EU_Sales" desc) as EUSalesRank, "EU_Sales", dense_rank() over (order by "NA_Sales" desc) as NASalesRank, "NA_Sales",
         dense_rank() over (order by "Other_Sales" desc) as OtherSalesRank, "Other_Sales", dense_rank() over (order by "JP_Sales" desc) as JPSalesRank, "JP_Sales" from salesinfo)

/*third, run a query to get the number 1 ranked selling game for each region.*/
select Regions.Region, gameSalesRankedPerRegion."Name", gameSalesRankedPerRegion."Platform",
  case
      when Regions.Region = 'North America' then gameSalesRankedPerRegion."NA_Sales"
      when Regions.Region = 'Europe' then gameSalesRankedPerRegion."EU_Sales"
      when Regions.Region = 'Japan' then gameSalesRankedPerRegion."JP_Sales"
      when Regions.Region = 'Other' then gameSalesRankedPerRegion."Other_Sales"
  end
       as salesPerMillion from Regions, gameSalesRankedPerRegion where
  case
      when Regions.Region = 'North America' then gameSalesRankedPerRegion.NASalesRank = 1
      when Regions.Region = 'Europe' then gameSalesRankedPerRegion.EUSalesRank = 1
      when Regions.Region = 'Japan' then gameSalesRankedPerRegion.JPSalesRank = 1
      when Regions.Region = 'Other' then gameSalesRankedPerRegion.OtherSalesRank = 1
  end);

select * from NumberOneGamePerRegion;

select gameinfo."Platform", gameinfo."Year_of_Release", sum(salesinfo."EU_Sales"+salesinfo."NA_Sales"+salesinfo."JP_Sales"+salesinfo."Other_Sales") as consoleGameSalesPerYear
from gameinfo left join salesinfo on salesinfo."Name" = gameinfo."Name" and salesinfo."Platform" = gameinfo."Platform" group by gameinfo."Platform", gameinfo."Year_of_Release" order by gameinfo."Platform", gameinfo."Year_of_Release";

select salesinfo."Name", sum("EU_Sales"+"NA_Sales"+"JP_Sales"+"Other_Sales")from salesinfo inner join gameinfo g on g."Name" = salesinfo."Name" and g."Platform" = salesinfo."Platform"
where "Year_of_Release" = 1985 and g."Platform" = 'DS'
group by salesinfo."Name";

/*remove duplicates from criticsinfo and salesinfo, as they may have duplicates since they only neeed to reference primary key from games info table*/
/*allocate the row number of which the clone is a clone, as that row number column will allow the clones to be differentiated from each other*/

/*this query returns the duplicates (after removal of them, they wont be there. also, can replace criticsinfo with salesinfo below in the select)*/
with rowNumCTE as (
    select *, (row_number() over (partition by "Name", "Platform" order by "Name", "Platform")) as row_num from criticsinfo
)
select * from rowNumCTE where row_num > 1;

/*OR alternatively use built in ctid which uniquely identifies rows in table. just select all rows where their ctids are NOT in a query of individual ctids where its the min ctid of a given name and platform
  (the logic is, if the outer ctid is not inside the subquerys ctid where its the min ctid of all ctids with the same name and platform, that means its a duplicate, as there should only be one ctid per name and platform
  since name and platform should be unique. so remove the non-min ctids of the same name and platform.)*/
select * FROM criticsinfo
WHERE ctid NOT IN (
  SELECT MIN(ctid)
  FROM criticsinfo
  GROUP BY "Name", "Platform"
);

/*below removes the duplicates found in the above query.*/
/*benefit of uniqueID is it makes it easier to uniquely identify and remove duplicates. just because foreign key refernces primary key, doesnt mean foreign key will necessarily be unique*/
/*below works as ctid is a built in unique identifier for rows in a table.*/
DELETE FROM salesinfo
WHERE ctid NOT IN (
  SELECT MIN(ctid)
  FROM salesinfo
  GROUP BY "Name", "Platform"
);

DELETE FROM criticsinfo
WHERE ctid NOT IN (
  SELECT MIN(ctid)
  FROM criticsinfo
  GROUP BY "Name", "Platform"
);
