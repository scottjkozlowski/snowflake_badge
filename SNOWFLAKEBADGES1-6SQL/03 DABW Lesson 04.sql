--SET role bqck to sysadmin
USE ROLE sysadmin;
USE DATABASE SMOOTHIES;

ALTER TABLE ORDERS ADD COLUMN NAME_ON_ORDER VARCHAR(100);

--check my SQL
insert into smoothies.public.orders(ingredients,name_on_order) values ('Apples ','Scott');

--check your table for rows with name populated
select * from orders where name_on_order is not null;

--add order filled to table orders
alter table smoothies.public.orders add column order_filled BOOLEAN DEFAULT FALSE;
--Update all orders from before we added name to it
update smoothies.public.orders
       set order_filled = true
       where name_on_order is null;

SELECT * from orders;

--Lesson 4 DORA check
-- Set your worksheet drop lists
USE ROLE ACCOUNTADMIN;
USE DATABASE UTIL_DB;

-- DO NOT EDIT ANYTHING BELOW THIS LINE
select GRADER(step, (actual = expected), actual, expected, description) as graded_results from (
  SELECT 'DABW004' as step
 ,( select count(*) from smoothies.information_schema.columns
    where table_schema = 'PUBLIC' 
    and table_name = 'ORDERS'
    and column_name = 'ORDER_FILLED'
    and column_default = 'FALSE'
    and data_type = 'BOOLEAN') as actual
 , 1 as expected
 ,'Order Filled is Boolean' as description
);