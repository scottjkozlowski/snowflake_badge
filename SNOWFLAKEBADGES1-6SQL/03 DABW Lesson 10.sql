USE ROLE SYSADMIN;
USE DATABASE SMOOTHIES;
ALTER TABLE FRUIT_OPTIONS ADD COLUMN SEARCH_ON VARCHAR(25);
--check what we have
select * from FRUIT_OPTIONS;
UPDATE FRUIT_OPTIONS SET SEARCH_ON = FRUIT_NAME WHERE SEARCH_ON IS NULL;

UPDATE FRUIT_OPTIONS SET SEARCH_ON = 'Apple' WHERE SEARCH_ON = 'Apples';
UPDATE FRUIT_OPTIONS SET SEARCH_ON = 'Blueberry' WHERE SEARCH_ON = 'Blueberries';
UPDATE FRUIT_OPTIONS SET SEARCH_ON = 'Raspberry' WHERE SEARCH_ON = 'Raspberries';
UPDATE FRUIT_OPTIONS SET SEARCH_ON = 'Elderberry' WHERE SEARCH_ON = 'Elderberries';
UPDATE FRUIT_OPTIONS SET SEARCH_ON = 'Fig' WHERE SEARCH_ON = 'Figs';
UPDATE FRUIT_OPTIONS SET SEARCH_ON = 'Strawberry' WHERE SEARCH_ON = 'Strawberries';
UPDATE FRUIT_OPTIONS SET SEARCH_ON = 'Dragonfruit' WHERE SEARCH_ON = 'Dragon Fruit';

-- Set your worksheet drop lists
USE ROLE ACCOUNTADMIN;
USE DATABASE UTIL_DB;
-- DO NOT EDIT ANYTHING BELOW THIS LINE
select GRADER(step, (actual = expected), actual, expected, description) as graded_results from (
   SELECT 'DABW008' as step 
   ,( select sum(hash_ing) from
      (select hash(ingredients) as hash_ing
       from smoothies.public.orders
       where order_ts is not null 
       and name_on_order is not null 
       and (name_on_order = 'Kevin' and order_filled = FALSE and hash_ing = 7976616299844859825) 
       or (name_on_order ='Divya' and order_filled = TRUE and hash_ing = -6112358379204300652)
       or (name_on_order ='Xi' and order_filled = TRUE and hash_ing = 1016924841131818535))
     ) as actual 
   , 2881182761772377708 as expected 
   ,'Followed challenge lab directions' as description
); 