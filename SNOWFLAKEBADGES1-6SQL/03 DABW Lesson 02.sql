USE ROLE SYSADMIN;
USE DATABASE SMOOTHIES;
USE SCHEMA PUBLIC;

CREATE OR REPLACE TABLE ORDERS(
    INGREDIENTS VARCHAR(200)
);

-- test the inline SQL from Sis

insert into smoothies.public.orders(ingredients) values ('CantaloupeGuavaJackfruitElderberriesFigs');

--check if table is populated
select * from ORDERS;

--empty the table to try again
truncate orders;

-- Set your worksheet drop lists
USE ROLE ACCOUNTADMIN;
USE DATABASE UTIL_DB;

-- DO NOT EDIT ANYTHING BELOW THIS LINE

select GRADER(step, (actual = expected), actual, expected, description) as graded_results from (
SELECT 'DABW002' as step
 ,(select IFF(count(*)>=5,5,0)
    from (select ingredients from smoothies.public.orders
    group by ingredients)
 ) as actual
 ,  5 as expected
 ,'At least 5 different orders entered' as description
);
