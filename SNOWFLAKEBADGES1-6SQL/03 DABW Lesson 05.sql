--SET role back to sysadmin
USE ROLE sysadmin;
USE DATABASE SMOOTHIES;
--CREATE SEQ for orders
CREATE OR REPLACE SEQUENCE order_seq
    start = 1
    increment = 2
    ORDER
    comment = 'Provide a unique id for each smoothie order';

--Remove rows from orders table so that sequence will populate
TRUNCATE TABLE ORDERS;

alter table SMOOTHIES.PUBLIC.ORDERS 
add column order_uid integer --adds the column
default smoothies.public.order_seq.nextval  --sets the value of the column to sequence
constraint order_uid unique enforced; --makes sure there is always a unique value in the column

--Check progress
select * from orders;

--Drop and create is what "replace" does!
create or replace table smoothies.public.orders (
       order_uid integer default smoothies.public.order_seq.nextval,
       order_filled boolean default false,
       name_on_order varchar(100),
       ingredients varchar(200),
       constraint order_uid unique (order_uid),
       order_ts timestamp_ltz default current_timestamp()
);
--DORA TIME
-- Set your worksheet drop lists
USE ROLE ACCOUNTADMIN;
USE DATABASE UTIL_DB;
-- DO NOT EDIT ANYTHING BELOW THIS LINE
select GRADER(step, (actual = expected), actual, expected, description) as graded_results from (
 SELECT 'DABW005' as step
 ,(select IFF(count(*)>=2, 2, 0) as num_sis_apps
    from (
        select count(*) as tally
        from snowflake.account_usage.query_history
        where query_text like 'execute streamlit%'
        group by query_text)
 ) as actual
 , 2 as expected
 ,'There seem to be 2 SiS Apps' as description
);