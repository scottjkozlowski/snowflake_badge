--SET THINGS UP FOR LESSON 5

USE ROLE SYSADMIN;
CREATE DATABASE MELS_SMOOTHIE_CHALLENGE_DB;
USE DATABASE MELS_SMOOTHIE_CHALLENGE_DB;
DROP SCHEMA PUBLIC;
CREATE OR REPLACE SCHEMA TRAILS;
USE SCHEMA TRAILS;
CREATE OR REPLACE STAGE TRAILS_GEOJSON ENCRYPTION = ( TYPE = 'SNOWFLAKE_SSE' );
CREATE OR REPLACE STAGE TRAILS_PARQUET ENCRYPTION = ( TYPE = 'SNOWFLAKE_SSE' );

CREATE OR REPLACE FILE FORMAT FF_JSON TYPE = JSON;
CREATE OR REPLACE FILE FORMAT FF_PARQUET TYPE = PARQUET;

SELECT * FROM @TRAILS_GEOJSON (FILE_FORMAT => FF_JSON);
SELECT * FROM @TRAILS_PARQUET (FILE_FORMAT => FF_PARQUET);

--dora time
USE ROLE ACCOUNTADMIN;
USE DATABASE UTIL_DB;

select GRADER(step, (actual = expected), actual, expected, description) as graded_results from
(
SELECT
'DLKW05' as step
 ,( select sum(tally)
   from
     (select count(*) as tally
      from mels_smoothie_challenge_db.information_schema.stages 
      union all
      select count(*) as tally
      from mels_smoothie_challenge_db.information_schema.file_formats)) as actual
 ,4 as expected
 ,'Camila\'s Trail Data is Ready to Query' as description
 );