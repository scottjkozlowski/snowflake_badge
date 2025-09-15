alter user SKSNOWFLAKE01 set default_warehouse = 'LLM_WH';
create or replace view camillas_db.forecasting.train_2_model_practice_data(
	practice_date,
	day_of_week,
	goals_attempted,
	goals_scored
) as
select 
practice_date,
dayname(practice_date) as day_of_week,
goals_attempted,
goals_scored
from camillas_db.forecasting.practice_stats
where practice_date < '2025-07-01';
create or replace view camillas_db.forecasting.validate_2_model_practice_data(
	practice_date,
	day_of_week,
	goals_attempted,
	goals_scored
) as
select 
practice_date,
dayname(practice_date) as day_of_week,
goals_attempted,
goals_scored
from camillas_db.forecasting.practice_stats
where practice_date < '2025-07-01';  
---------Added this block to fix second view for forcasting myself

create or replace view CAMILLAS_DB.FORECASTING.VALIDATE_2_MODEL_PRACTICE_DATA(
	PRACTICE_DATE,
    day_of_week,
	GOALS_ATTEMPTED,
	GOALS_SCORED
) as
  select 
    practice_date, 
    dayname(practice_date) as day_of_week,
    goals_attempted,
    goals_scored
  from camillas_db.forecasting.practice_stats
  where practice_date >= '2025-07-01';

---------------- This is how I found tested the DORA test for curiosity for the LLM class portion
select model_name
       from SNOWFLAKE.ACCOUNT_USAGE.CORTEX_FUNCTIONS_USAGE_HISTORY
       where function_name = 'COMPLETE'
       group by model_name;


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
-- Set your worksheet drop lists
-- DO NOT EDIT ANYTHING BELOW THIS LINE
select GRADER(step, (actual = expected), actual, expected, description) as graded_results from (
   SELECT 'DSCW04' as step 
   ,( select  round(count(*)/iff(count(*)=0,1,count(*)),0) as tally
      from snowflake.account_usage.query_history
      where query_text like '%CREATE SNOWFLAKE.ML.FORECAST camillas_practice_goal_4cast%'
      and execution_status = 'SUCCESS'
     ) as actual 
   , 1 as expected 
   ,'Improved Forecast Model' as description
); 