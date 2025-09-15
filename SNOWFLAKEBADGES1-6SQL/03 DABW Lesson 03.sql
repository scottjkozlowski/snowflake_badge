--location to find snowflake SiS cmpatible packakes but be sure to verify with example
--URL: https://repo.anaconda.com/pkgs/snowflake/

--Lesson 3 DORA
-- Set your worksheet drop lists
USE ROLE ACCOUNTADMIN;
USE DATABASE UTIL_DB;

-- DO NOT EDIT ANYTHING BELOW THIS LINE
select GRADER(step, (actual = expected), actual, expected, description) as graded_results from (
  SELECT 'DABW003' as step
 ,(select ascii(fruit_name) from smoothies.public.fruit_options
where fruit_name ilike 'z%') as actual
 , 90 as expected
 ,'A mystery check for the inquisitive' as description
);