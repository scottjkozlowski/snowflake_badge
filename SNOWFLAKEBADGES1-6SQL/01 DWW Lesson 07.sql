--Loading tables from a file CSV, TXT, and JSON

create table garden_plants.veggies.vegetable_details
(
plant_name varchar(25)
, root_depth_code varchar(1)    
);

--After building this table stage was used to load CSV file via GUI

--DORA TEST BELOW

--Set your worksheet drop list role to ACCOUNTADMIN
--Set your worksheet drop list database and schema to the location of your GRADER function

-- DO NOT EDIT ANYTHING BELOW THIS LINE. THE CODE MUST BE RUN EXACTLY AS IT IS WRITTEN
select GRADER(step, (actual = expected), actual, expected, description) as graded_results from (
 SELECT 'DWW06' as step
 ,( select count(*) 
   from GARDEN_PLANTS.INFORMATION_SCHEMA.TABLES 
   where table_name = 'VEGETABLE_DETAILS') as actual
 , 1 as expected
 ,'VEGETABLE_DETAILS Table' as description
);

--Looking for trouble, two Spinach...
select * from vegetable_details;
--While looking at the results switch view to chart and note the count of 2 spinach rows

--See it better
select * from vegetable_details
where plant_name = 'Spinach';

--Isolate rows in question in prep for removal
select * from vegetable_details
where plant_name = 'Spinach'
and root_depth_code = 'D';

--Clen up the mess replacing the the "select *" with "delete from"
delete from vegetable_details
where plant_name = 'Spinach'
and root_depth_code = 'D';

--DORA check 7
--Set your worksheet drop list role to ACCOUNTADMIN
--Set your worksheet drop list database and schema to the location of your GRADER function

-- DO NOT EDIT ANYTHING BELOW THIS LINE. THE CODE MUST BE RUN EXACTLY AS IT IS WRITTEN
select GRADER(step, (actual = expected), actual, expected, description) as graded_results from (
 SELECT 'DWW07' as step
 ,( select row_count 
   from GARDEN_PLANTS.INFORMATION_SCHEMA.TABLES 
   where table_name = 'VEGETABLE_DETAILS') as actual
 , 41 as expected
 , 'VEG_DETAILS row count' as description
);


