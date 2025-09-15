//USE SYSADMIN role, LIBRARY_CARD_CATALOG database, and PUBLIC schema

USE ROLE SYSADMIN;
USE DATABASE LIBRARY_CARD_CATALOG;
USE SCHEMA PUBLIC;

// Create an Ingestion Table for the NESTED JSON Data
create or replace table library_card_catalog.public.nested_ingest_json 
(
  raw_nested_book VARIANT
);

//Query the uplaoded file from stage to verify file contents, and applied file format 
select $1
from @util_db.public.my_internal_stage/json_book_author_nested.txt
(file_format => library_card_catalog.public.JSON_FILE_FORMAT);

// Copy data from file into table using file format
copy into nested_ingest_json
from @util_db.public.my_internal_stage
files = ( 'json_book_author_nested.txt')
file_format = ( format_name=library_card_catalog.public.JSON_FILE_FORMAT );

//a few simple queries
select raw_nested_book
from nested_ingest_json;

select raw_nested_book:year_published
from nested_ingest_json;

select raw_nested_book:authors
from nested_ingest_json;

//Use these example flatten commands to explore flattening the nested book and author data
select value:first_name
from nested_ingest_json
,lateral flatten(input => raw_nested_book:authors);

select value:first_name
from nested_ingest_json
,table(flatten(raw_nested_book:authors));

//Add a CAST command to the fields returned
SELECT value:first_name::varchar, value:last_name::varchar
from nested_ingest_json
,lateral flatten(input => raw_nested_book:authors);

//Assign new column  names to the columns using "AS"
select value:first_name::varchar as first_nm
, value:last_name::varchar as last_nm
from nested_ingest_json
,lateral flatten(input => raw_nested_book:authors);

//USE UTIL_DB database, and PUBLIC schema

USE ROLE ACCOUNTADMIN;
USE DATABASE UTIL_DB;
USE SCHEMA PUBLIC;

-- Set your worksheet drop lists. DO NOT EDIT THE DORA CODE.

select GRADER(step, (actual = expected), actual, expected, description) as graded_results from (   
     SELECT 'DWW17' as step 
      ,( select row_count 
        from LIBRARY_CARD_CATALOG.INFORMATION_SCHEMA.TABLES 
        where table_name = 'NESTED_INGEST_JSON') as actual 
      , 5 as expected 
      ,'Check number of rows' as description  
);

//CHANGE ROLE to SYSADMIN, CREATE DATABASE
//LIBRARY_CARD_CATALOG database, and PUBLIC schema

USE ROLE SYSADMIN;
CREATE database SOCIAL_MEDIA_FLOODGATES comment = 'DWW Lesson 12';
USE DATABASE SOCIAL_MEDIA_FLOODGATES;
USE SCHEMA PUBLIC;
CREATE or replace table TWEET_INGEST
(
  RAW_STATUS VARIANT
);
//Create File Format for JSON Data 
create or replace file format json_file_format
type = 'JSON' 
compression = 'AUTO' 
enable_octal = FALSE
allow_duplicate = FALSE 
strip_outer_array = TRUE
strip_null_values = FALSE 
ignore_utf8_errors = FALSE;

select $1
from @util_db.public.my_internal_stage/nutrition_tweets.json
(file_format => library_card_catalog.public.JSON_FILE_FORMAT);

copy into TWEET_INGEST
from @util_db.public.my_internal_stage
files = ( 'nutrition_tweets.json')
file_format = ( format_name=social_media_floodgates.public.json_file_format );

//simple select statements -- are you seeing 9 rows?
select raw_status
from tweet_ingest;

select raw_status:entities
from tweet_ingest;

select raw_status:entities:hashtags
from tweet_ingest;

//Explore looking at specific hashtags by adding bracketed numbers
//This query returns just the first hashtag in each tweet
select raw_status:entities:hashtags[0].text
from tweet_ingest;

//This version adds a WHERE clause to get rid of any tweet that 
//doesn't include any hashtags
select raw_status:entities:hashtags[0].text
from tweet_ingest
where raw_status:entities:hashtags[0].text is not null;

//Perform a simple CAST on the created_at key
//Add an ORDER BY clause to sort by the tweet's creation date
select raw_status:created_at::date
from tweet_ingest
order by raw_status:created_at::date;

//Flatten statements can return nested entities only (and ignore the higher level objects)
select value
from tweet_ingest
,lateral flatten
(input => raw_status:entities:urls);

select value
from tweet_ingest
,table(flatten(raw_status:entities:urls));

//Flatten and return just the hashtag text, CAST the text as VARCHAR
select value:text::varchar as hashtag_used
from tweet_ingest
,lateral flatten
(input => raw_status:entities:hashtags);

//Add the Tweet ID and User ID to the returned table so we could join the hashtag back to it's source tweet
select raw_status:user:name::text as user_name
,raw_status:id as tweet_id
,value:text::varchar as hashtag_used
from tweet_ingest
,lateral flatten
(input => raw_status:entities:hashtags);

USE ROLE ACCOUNTADMIN;
USE DATABASE UTIL_DB;
USE SCHEMA PUBLIC;

-- Set your worksheet drop lists. DO NOT EDIT THE DORA CODE.
select GRADER(step, (actual = expected), actual, expected, description) as graded_results from
(
   SELECT 'DWW18' as step
  ,( select row_count 
    from SOCIAL_MEDIA_FLOODGATES.INFORMATION_SCHEMA.TABLES 
    where table_name = 'TWEET_INGEST') as actual
  , 9 as expected
  ,'Check number of rows' as description  
 ); 

USE ROLE SYSADMIN;
USE DATABASE SOCIAL_MEDIA_FLOODGATES;
USE SCHEMA PUBLIC;

 create or replace view social_media_floodgates.public.urls_normalized as
(select raw_status:user:name::text as user_name
,raw_status:id as tweet_id
,value:display_url::text as url_used
from tweet_ingest
,lateral flatten
(input => raw_status:entities:urls)
);

SELECT * FROM URLS_NORMALIZED;

create or replace view social_media_floodgates.public.HASHTAGS_NORMALIZED as
(select raw_status:user:name::text as user_name
,raw_status:id as tweet_id
,value:text::varchar as hashtag_used
from tweet_ingest
,lateral flatten
(input => raw_status:entities:hashtags)
);

SELECT * FROM hashtags_normalized;

USE ROLE ACCOUNTADMIN;
USE DATABASE UTIL_DB;
USE SCHEMA PUBLIC;

-- Set your worksheet drop lists. DO NOT EDIT THE DORA CODE.

select GRADER(step, (actual = expected), actual, expected, description) as graded_results from
(
  SELECT 'DWW19' as step
  ,( select count(*) 
    from SOCIAL_MEDIA_FLOODGATES.INFORMATION_SCHEMA.VIEWS 
    where table_name = 'HASHTAGS_NORMALIZED') as actual
  , 1 as expected
  ,'Check number of rows' as description
 );