--new set up stuff
alter user SKSNOWFLAKE01 set default_role = 'SYSADMIN';
alter user SKSNOWFLAKE01 set default_warehouse = 'COMPUTE_WH';
alter user SKSNOWFLAKE01 set default_namespace = 'UTIL_DB.PUBLIC';
--set the stage
USE ROLE SYSADMIN;
USE DATABASE UTIL_DB;
USE WAREHOUSE COMPUTE_WH;

--Build new DB and use it
CREATE OR REPLACE DATABASE AGS_GAME_AUDIENCE;
USE DATABASE AGS_GAME_AUDIENCE;

--Drop old PUBLIC schema and replace it with RAW schema and USE it
DROP SCHEMA PUBLIC;
CREATE OR REPLACE SCHEMA RAW;
USE SCHEMA RAW;

--Create new table GAME_LOGS
CREATE OR REPLACE TABLE GAME_LOGS (RAW_LOG VARIANT);

--CREATE an external stage via GUI and the query it 
CREATE OR REPLACE STAGE uni_kishore 
	URL = 's3://uni-kishore' 
	DIRECTORY = ( ENABLE = true );
LIST @uni_kishore/kickoff;

--Create file format for viewing external stage
CREATE OR REPLACE FILE FORMAT FF_JSON_LOGS
    TYPE = JSON 
    STRIP_OUTER_ARRAY = TRUE;

SELECT $1 
FROM @uni_kishore/kickoff
(FILE_FORMAT => FF_JSON_LOGS);

--Load table from external stage and query it using formatting for json columns
copy into game_logs from @uni_kishore/kickoff file_format = (format_name=FF_JSON_LOGS);
SELECT 
    RAW_LOG:agent::text as AGENT,
    RAW_LOG:datetime_iso8601::TIMESTAMP_NTZ as datetime_iso8601,
    RAW_LOG:user_event::text as USER_EVENT,
    RAW_LOG:user_login::text as USER_LOGIN,
    --*
    RAW_LOG::VARIANT AS RAWLOG
FROM GAME_LOGS;

--Creat a view from new select
CREATE OR REPLACE VIEW LOGS AS (
    SELECT 
        RAW_LOG:agent::text as AGENT,
        RAW_LOG:datetime_iso8601::TIMESTAMP_NTZ as datetime_iso8601,
        RAW_LOG:user_event::text as USER_EVENT,
        RAW_LOG:user_login::text as USER_LOGIN,
        --*
        RAW_LOG::VARIANT AS RAWLOG
    FROM GAME_LOGS
);

--Test new view with select statement
SELECT * from LOGS;

  select count(*)  
      from ags_game_audience.raw.logs
      where is_timestamp_ntz(to_variant(datetime_iso8601))= TRUE ;

-- WACKY DORA TIME
USE DATABASE UTIL_DB;
USE SCHEMA PUBLIC;
-- DO NOT EDIT THIS CODE
select GRADER(step, (actual = expected), actual, expected, description) as graded_results from
(
 SELECT
 'DNGW01' as step
  ,(
      select count(*)  
      from ags_game_audience.raw.logs
      where is_timestamp_ntz(to_variant(datetime_iso8601))= TRUE 
   ) as actual
, 250 as expected
, 'Project DB and Log File Set Up Correctly' as description
);