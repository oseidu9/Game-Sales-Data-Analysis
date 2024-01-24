select * from datacleangamesalesinfo.gamesalesinfo;

/*first, convert Year_Of_Release from int to date format (but only year, no neeed to include empty day and time)*/
/*when using to_date function, the date datatype must be cast to text*/
ALTER TABLE datacleangamesalesinfo.gamesalesinfo ALTER COLUMN "Year_of_Release" TYPE DATE
using to_date("Year_of_Release"::text, 'YYYY');

/*cant seem to find a way to leave only year presented in the table (without the 01-01, but at least example of change nonetheless)*/
select "Year_of_Release" from datacleangamesalesinfo.gamesalesinfo;

/*in the case where developer is null and Publisher is not, assume the developer and publisher are the same (postgresql equivalent of isnull() is coalesce())*/
select * from datacleangamesalesinfo.gamesalesinfo where ("Publisher" is not null and "Developer" is null);

update datacleangamesalesinfo.gamesalesinfo
set "Developer" = COALESCE("Developer","Publisher")
where "Developer" is null;

/*separate extra developers into new columns (e.g. if there is more than one developer in  devleoper column, create new column other_developers.)
  Assume comma is delimiter (assume comma separates devs in the single dev column. Not entirely correct but for sake of delimiter practice)*/
  /*could be better by ACTUALLY formatting data properly in excel so comma delimiter is actually correct
    Can talk about importance of data formatting before sql import, which would allow for correct delimiter use.*/
select * from datacleangamesalesinfo.gamesalesinfo where "Developer" like '%Pipeworks Software%';

/*select substring of dev. go from first character to first time you see a comma, then go back one step
  Note: can also use SPLIT_PART to do this.*/
select substring("Developer", 1, strpos("Developer", ',') -1), substring("Developer", strpos("Developer", ',')+1, length("Developer"))
       from datacleangamesalesinfo.gamesalesinfo where substring("Developer", 1, strpos("Developer", ',')) != '';

/*add new table which will hold other developers*/
ALTER TABLE datacleangamesalesinfo.gamesalesinfo
add "Other_Developers" varchar;

/*update otherDevelopers column FIRST since original developer column would be different if we updated that one first*/
update datacleangamesalesinfo.gamesalesinfo
set "Other_Developers" = substring("Developer", strpos("Developer", ',')+1, length("Developer")) where substring("Developer", 1, strpos("Developer", ',')) != '';

/*update original developer column to only hold first developer before the comma*/
update datacleangamesalesinfo.gamesalesinfo
set "Developer" = substring("Developer", 1, strpos("Developer", ',') -1) where substring("Developer", 1, strpos("Developer", ',')) != '';

/*lets change "null" rating to no rating specified
  */
select case
    when "Rating" is null then 'No Rating Specified'
    else "Rating"
    end
    as Rating
    from datacleangamesalesinfo.gamesalesinfo;

update datacleangamesalesinfo.gamesalesinfo
set "Rating" = case
    when "Rating" is null then 'No Rating Specified'
    else "Rating"
    end;

/*lets change "null" other_developers to none
  */
  update datacleangamesalesinfo.gamesalesinfo
set "Other_Developers" = case
    when "Other_Developers" is null then 'None'
    else "Other_Developers"
    end;

/*for removing of duplicates, go to bottom of queries.sql.*/
