select GRADER(step, (actual = expected), actual, expected, description) as graded_results from (
   SELECT 'DSCW01' as step 
   ,( select  iff(count(*)>=5, 5, 0)
     from (;
       select model_name
       from SNOWFLAKE.ACCOUNT_USAGE.CORTEX_FUNCTIONS_USAGE_HISTORY
       where function_name = 'COMPLETE'
       group by model_name;
          )
     ) as actual 
   , 5 as expected 
   ,'Used Different models when exploring Cortex Playground' as description
);