--Set the stage using existing DB, create and use new schema, and add a new standar xtra-small warehouse
USE ROLE SYSADMIN;
USE DATABASE CAMILLAS_DB;
CREATE SCHEMA FORECASTING;
USE SCHEMA FORECASTING;
CREATE WAREHOUSE ML_WH WAREHOUSE_TYPE = STANDARD WAREHOUSE_SIZE = XSMALL;
--Create a table for stats
create or replace table camillas_db.forecasting.practice_stats (
	practice_date timestamp_ntz,
	goals_scored number,
	goals_attempted number
);
--Create an internal stage with client side encryption
CREATE OR REPLACE STAGE CSV_LOAD ENCRYPTION = (TYPE = 'SNOWFLAKE_FULL') DIRECTORY = (ENABLE = TRUE);
list @CAMILLAS_DB.FORECASTING.CSV_LOAD;

CREATE OR REPLACE FILE FORMAT FF_STATS_CSV 
    TYPE = CSV,
    SKIP_HEADER = 1,
    FIELD_DELIMITER = ',';
--Use snowsite GUI to place file into stage
--Load stats table
select $1, $2, $3 
from @CAMILLAS_DB.FORECASTING.CSV_LOAD/stats_collected_at_practice.csv
(file_format => CAMILLAS_DB.FORECASTING.FF_STATS_CSV);

COPY INTO camillas_db.forecasting.practice_stats 
from @CAMILLAS_DB.FORECASTING.CSV_LOAD
files = ('stats_collected_at_practice.csv')
FILE_FORMAT =FF_STATS_CSV;
select* from camillas_db.forecasting.practice_stats;

-- make a view that uses data from march to july for training the model 
create or replace view camillas_db.forecasting.train_model_practice_data(
	  practice_date,
	  goals_attempted,
	  goals_scored
) as
  select 
    practice_date, 
    goals_attempted,
    goals_scored
  from camillas_db.forecasting.practice_stats
  where practice_date < '2025-07-01';


-- make a view that uses data from july forward for validating the model
create or replace view camillas_db.forecasting.validate_model_practice_data(
	   practice_date,
	   goals_attempted,
	   goals_scored
) as
  select 
    practice_date, 
    goals_attempted,
    goals_scored
  from camillas_db.forecasting.practice_stats
  where practice_date >= '2025-07-01';


-- Set your worksheet drop lists
-- DO NOT EDIT ANYTHING BELOW THIS LINE
select GRADER(step, (actual = expected), actual, expected, description) as graded_results from (
   SELECT 'DSCW03' as step 
   ,( select  round(count(*)/iff(count(*)=0,1,count(*)),0) as tally
      from snowflake.account_usage.query_history
      where query_text like '%CREATE SNOWFLAKE.ML.FORECAST camillas_practice_goal_forecasting%'
      and execution_status = 'SUCCESS'
     ) as actual 
   , 1 as expected 
   ,'Created Forecast Model' as description
);