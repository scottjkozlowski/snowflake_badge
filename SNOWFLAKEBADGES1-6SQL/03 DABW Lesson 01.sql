--Set things up incliding role selection, creation of new DB named SMOOTHIES and then select the DB, SCHEMA, and WAREHOUSE
USE ROLE SYSADMIN;
USE WAREHOUSE COMPUTE_WH;
CREATE OR REPLACE DATABASE SMOOTHIES COMMENT = 'Database to hold smoothie types and ingrediants';
USE DATABASE SMOOTHIES;
USE SCHEMA PUBLIC;

--Create a Fruits DB for our streamlit app
CREATE OR REPLACE TABLE FRUIT_OPTIONS (
    FRUIT_ID NUMBER,
    FRUIT_NAME VARCHAR(25)
    );

create file format smoothies.public.two_headerrow_pct_delim
   type = CSV,
   skip_header = 2,   
   field_delimiter = '%',
   trim_space = TRUE
;

--Query file sin the newly created internal stage
SELECT $1, $2
FROM @MY_UPLOADED_FILES/fruits_available_for_smoothies.txt
(FILE_FORMAT => two_headerrow_pct_delim);

--Use to try an load staged file
COPY INTO smoothies.public.fruit_options
from ( select $2 as FRUIT_ID, $1 as FRUIT_NAME
from @smoothies.public.my_uploaded_files/fruits_available_for_smoothies.txt )
file_format = (format_name = smoothies.public.two_headerrow_pct_delim)
on_error = abort_statement
purge = true;

--Become account admin and run dora test then switch back to SYSADMIN
USE ROLE ACCOUNTADMIN;
USE DATABASE UTIL_DB;
USE SCHEMA PUBLIC;
-- Remember that you MUST USE ACCOUNTADMIN and UTIL_DB.PUBLIC as your context anytime you run DORA checks!!
-- DO NOT EDIT ANYTHING BELOW THIS LINE
select grader(step, (actual = expected), actual, expected, description) as graded_results from 
  ( SELECT 
  'DORA_IS_WORKING' as step
 ,(select 223) as actual
 , 223 as expected
 ,'Dora is working!' as description
);

-- Set your worksheet drop lists
-- DO NOT EDIT ANYTHING BELOW THIS LINE
select GRADER(step, (actual = expected), actual, expected, description) as graded_results from (
  SELECT 'DABW001' as step
 ,( select count(*) 
   from SMOOTHIES.PUBLIC.FRUIT_OPTIONS) as actual
 , 25 as expected
 ,'Fruit Options table looks good' as description
);

USE ROLE SYSADMIN;
USE DATABASE SMOOTHIES;
USE SCHEMA PUBLIC;
