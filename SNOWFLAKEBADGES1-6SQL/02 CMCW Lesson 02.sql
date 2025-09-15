--Dropping a share, don't worry we get it back through the gui 
--alter database SCOTTS_REALLY_COOL_DATA
--rename to snowflake_sample_data;
select * from garden_plants.veggies.vegetable_details;

--Check the range of values in the Market Segment Column
select distinct c_mktsegment
from snowflake_sample_data.tpch_sf1.customer;

--Find out which Market Segments have the most customers
select c_mktsegment, count(*)
from snowflake_sample_data.tpch_sf1.customer
group by c_mktsegment
order by count(*);

-- Nations Table
select n_nationkey, n_name, n_regionkey
from snowflake_sample_data.tpch_sf1.nation;


-- Regions Table
select r_regionkey, r_name
from snowflake_sample_data.tpch_sf1.region;


-- Join the Tables and Sort
select r_name as region, n_name as nation
from snowflake_sample_data.tpch_sf1.nation
join snowflake_sample_data.tpch_sf1.region
on n_regionkey = r_regionkey
order by r_name, n_name asc;

--Group and Count Rows Per Region
select r_name as region, count(n_name) as num_countries
from snowflake_sample_data.tpch_sf1.nation
join snowflake_sample_data.tpch_sf1.region
on n_regionkey = r_regionkey
group by r_name;

-- where did you put the function?
show user functions in account;

-- did you put it here?
select * 
from util_db.information_schema.functions
where function_name = 'GRADER'
and function_catalog = 'UTIL_DB'
and function_owner = 'SYSADMIN';

--uncomment below and set role to SYSYADMIN if they do not already own GRADER function
--grant usage 
--on function UTIL_DB.PUBLIC.GRADER(VARCHAR, BOOLEAN, NUMBER, NUMBER, VARCHAR) 
--to <role>;

USE UTIL_DB.PUBLIC;
select GRADER(step,(actual = expected), actual, expected, description) as graded_results from (
SELECT 'DORA_IS_WORKING' as step
 ,(select 223 ) as actual
 ,223 as expected
 ,'Dora is working!' as description
);

--Have SYSADMIN create a new DB bamed INTL_DB and select the PUBLIC schema
use role SYSADMIN;

create database INTL_DB;

use schema INTL_DB.PUBLIC;

--Create a warehouse owned by SYADMIN named INTL_WH using settings below
use role SYSADMIN;

create warehouse INTL_WH 
with 
warehouse_size = 'XSMALL' 
warehouse_type = 'STANDARD' 
auto_suspend = 600 --600 seconds/10 mins
auto_resume = TRUE;

use warehouse INTL_WH;

--Create table INT_STDS_ORG_3166
create or replace table intl_db.public.INT_STDS_ORG_3166 
(iso_country_name varchar(100), 
 country_name_official varchar(200), 
 sovreignty varchar(40), 
 alpha_code_2digit varchar(2), 
 alpha_code_3digit varchar(3), 
 numeric_country_code integer,
 iso_subdivision varchar(15), 
 internet_domain_code varchar(10)
);

--Create a file format
create or replace file format util_db.public.PIPE_DBLQUOTE_HEADER_CR 
  type = 'CSV' --use CSV for any flat file
  compression = 'AUTO' 
  field_delimiter = '|' --pipe or vertical bar
  record_delimiter = '\r' --carriage return
  skip_header = 1  --1 header row
  field_optionally_enclosed_by = '\042'  --double quotes
  trim_space = FALSE;

--Check for stages in account
show stages in account;

--build new stage
create stage util_db.public.aws_s3_bucket url = 's3://uni-cmcw';

--examine file to be copied
list @util_db.public.aws_s3_bucket;

--not exactly iso_countries_utf8_pipe.csv but more like ISO_Countries_UTF8_pipe.csv

--finally a copy into
copy into INT_STDS_ORG_3166
from @util_db.public.AWS_S3_BUCKET
files = ( 'ISO_Countries_UTF8_pipe.csv')
file_format = ( format_name='util_db.public.PIPE_DBLQUOTE_HEADER_CR' );

--check your work
select count(*) as found, '249' as expected 
from INTL_DB.PUBLIC.INT_STDS_ORG_3166;

--then comes DORA

-- set your worksheet drop lists or write and run USE commands
-- YOU WILL NEED TO USE ACCOUNTADMIN ROLE on this test.

USE ROLE ACCOUNTADMIN;
USE DATABASE UTIL_DB;
USE SCHEMA PUBLIC;

--DO NOT EDIT BELOW THIS LINE
select grader(step, (actual = expected), actual, expected, description) as graded_results from( 
 SELECT 'CMCW01' as step
 ,( select count(*) 
   from snowflake.account_usage.databases
   where database_name = 'INTL_DB' 
   and deleted is null) as actual
 , 1 as expected
 ,'Created INTL_DB' as description
 );

-- We can "ask" the Information Schema Table called "Tables" if our table exists by asking it to count the number of times a table with that name, in a certain schema, in a certain database (catalog) exists. If it exists, we should get back the count of 1. 

select count(*) as OBJECTS_FOUND
from <database name>.INFORMATION_SCHEMA.TABLES 
where table_schema=<schema name> 
and table_name= <table name>;

--So if we are looking for INTL_DB.PUBLIC.INT_STDS_ORG_3166 we can run this command to check: 

--Does a table with that name exist...in a certain schema...within a certain database.

select count(*) as OBJECTS_FOUND
from INTL_DB.INFORMATION_SCHEMA.TABLES 
where table_schema='PUBLIC'
and table_name= 'INT_STDS_ORG_3166';

--We can "ask" the Information Schema Table called "Tables" if our table has the expected number of rows with a command like this:

select row_count
from <database name>.INFORMATION_SCHEMA.TABLES 
where table_schema=<schema name> 
and table_name= <table name>;

--So if we are looking to see how many rows are contained in INTL_DB.PUBLIC.INT_STDS_ORG_3166 we can run this command to check: 

--For the table we presume exists...in a certain schema...within a certain database...how many rows does the table hold?

select row_count
from INTL_DB.INFORMATION_SCHEMA.TABLES 
where table_schema='PUBLIC'
and table_name= 'INT_STDS_ORG_3166';

-- set your worksheet drop lists to the location of your GRADER function
-- role can be set to either SYSADMIN or ACCOUNTADMIN for this check

USE ROLE ACCOUNTADMIN;
USE DATABASE UTIL_DB;
USE SCHEMA PUBLIC;

--DO NOT EDIT BELOW THIS LINE
select grader(step, (actual = expected), actual, expected, description) as graded_results from(
SELECT 'CMCW02' as step
 ,( select count(*) 
   from INTL_DB.INFORMATION_SCHEMA.TABLES 
   where table_schema = 'PUBLIC' 
   and table_name = 'INT_STDS_ORG_3166') as actual
 , 1 as expected
 ,'ISO table created' as description
);

-- set your worksheet drop lists to the location of your GRADER function 
-- either role can be used

-- DO NOT EDIT BELOW THIS LINE 
select grader(step, (actual = expected), actual, expected, description) as graded_results from( 
SELECT 'CMCW03' as step 
 ,(select row_count 
   from INTL_DB.INFORMATION_SCHEMA.TABLES  
   where table_name = 'INT_STDS_ORG_3166') as actual 
 , 249 as expected 
 ,'ISO Table Loaded' as description 
);