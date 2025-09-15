--Have SYSADMIN create a new DB named INTL_DB and select the PUBLIC schema
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

--Build a select statement upon which to base  your view
select  
     iso_country_name
    ,country_name_official,alpha_code_2digit
    ,r_name as region
from INTL_DB.PUBLIC.INT_STDS_ORG_3166 i
left join SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.NATION n
on upper(i.iso_country_name)= n.n_name
left join SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.REGION r
on n_regionkey = r_regionkey;

--Now surround the prior select statement to create a view
create or replace view intl_db.public.NATIONS_SAMPLE_PLUS_ISO 
( iso_country_name
  ,country_name_official
  ,alpha_code_2digit
  ,region) AS
  select  
     iso_country_name
    ,country_name_official,alpha_code_2digit
    ,r_name as region
from INTL_DB.PUBLIC.INT_STDS_ORG_3166 i
left join SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.NATION n
on upper(i.iso_country_name)= n.n_name
left join SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.REGION r
on n_regionkey = r_regionkey
;

-- and now you can query the new view
select *
from intl_db.public.NATIONS_SAMPLE_PLUS_ISO;

-- SET YOUR DROPLISTS PRIOR TO RUNNING THE CODE BELOW 
USE ROLE ACCOUNTADMIN;
USE DATABASE UTIL_DB;
USE SCHEMA PUBLIC;

--DO NOT EDIT BELOW THIS LINE
select grader(step, (actual = expected), actual, expected, description) as graded_results from(
SELECT 'CMCW04' as step
 ,( select count(*) 
   from INTL_DB.PUBLIC.NATIONS_SAMPLE_PLUS_ISO) as actual
 , 249 as expected
 ,'Nations Sample Plus Iso' as description
);


--create table currencies
USE ROLE SYSADMIN;
USE DATABASE INTL_DB;
USE SCHEMA PUBLIC;
create table intl_db.public.CURRENCIES 
(
  currency_ID integer, 
  currency_char_code varchar(3), 
  currency_symbol varchar(4), 
  currency_digital_code varchar(3), 
  currency_digital_name varchar(30)
)
  comment = 'Information about currencies including character codes, symbols, digital codes, etc.';

--create table country_to_currencycode
create table intl_db.public.COUNTRY_CODE_TO_CURRENCY_CODE 
  (
    country_char_code varchar(3), 
    country_numeric_code integer, 
    country_name varchar(100), 
    currency_name varchar(100), 
    currency_char_code varchar(3), 
    currency_numeric_code integer
  ) 
  comment = 'Mapping table currencies to countries';

--create file frmat for loading 2 new tables
create file format util_db.public.CSV_COMMA_LF_HEADER
  type = 'CSV' 
  field_delimiter = ',' 
  record_delimiter = '\n' -- the n represents a Line Feed character
  skip_header = 1 
;

--examine files to be copied
list @util_db.public.aws_s3_bucket;

--finally a copy into
copy into intl_db.public.CURRENCIES
from @util_db.public.AWS_S3_BUCKET
files = ( 'currencies.csv')
file_format = ( format_name='util_db.public.CSV_COMMA_LF_HEADER' );

copy into intl_db.public.COUNTRY_CODE_TO_CURRENCY_CODE
from @util_db.public.AWS_S3_BUCKET
files = ( 'country_code_to_currency_code.csv')
file_format = ( format_name='util_db.public.CSV_COMMA_LF_HEADER' );

--DORA check
-- set your worksheet drop lists
USE ROLE ACCOUNTADMIN;
USE DATABASE UTIL_DB;
USE SCHEMA PUBLIC;

--DO NOT EDIT BELOW THIS LINE
select grader(step, (actual = expected), actual, expected, description) as graded_results from(
SELECT 'CMCW05' as step
 ,(select row_count 
  from INTL_DB.INFORMATION_SCHEMA.TABLES 
  where table_schema = 'PUBLIC' 
  and table_name = 'COUNTRY_CODE_TO_CURRENCY_CODE') as actual
 , 265 as expected
 ,'CCTCC Table Loaded' as description
);

--DORA again
-- set your worksheet context menus

--DO NOT EDIT BELOW THIS LINE
select grader(step, (actual = expected), actual, expected, description) as graded_results from(
SELECT 'CMCW06' as step
 ,(select row_count 
  from INTL_DB.INFORMATION_SCHEMA.TABLES 
  where table_schema = 'PUBLIC' 
  and table_name = 'CURRENCIES') as actual
 , 151 as expected
 ,'Currencies table loaded' as description
);

--return to original seetings
USE ROLE SYSADMIN;
USE DATABASE INTL_DB;

--Create SIMPLE_CURRENCY view
CREATE OR REPLACE VIEW INTL_DB.PUBLIC.SIMPLE_CURRENCY(
    CTY_CODE,
    CUR_CODE
) AS 
select COUNTRY_CHAR_CODE AS CTY_CODE, CURRENCY_CHAR_CODE AS CUR_CODE from intl_db.public.country_code_to_currency_code;

--check you work
select * from simple_currency;

--DORA time again
-- don't forget your droplists
USE ROLE ACCOUNTADMIN;
USE DATABASE UTIL_DB;
USE SCHEMA PUBLIC;

--DO NOT EDIT BELOW THIS LINE
select grader(step, (actual = expected), actual, expected, description) as graded_results from(
 SELECT 'CMCW07' as step 
,( select count(*) 
  from INTL_DB.PUBLIC.SIMPLE_CURRENCY ) as actual
, 265 as expected
,'Simple Currency Looks Good' as description
);