--Create a variable and set its value then display it using a select
set mystery_bag = 'This bag is empty!!';
select $mystery_bag;

set var1 = 2;
set var2 = 5;
set var3 = 7;

select $var1+$var2+$var3;

USE ROLE SYSADMIN;
USE DATABASE UTIL_DB;
create or replace function sum_mystery_bag_vars (var1 number, var2 number, var3 number)
    returns number as 'select var1+var2+var3';
select sum_mystery_bag_vars (12,36,204);

--one more thing
set eeny = 4;
set meeny = 67.2;
set miney_mo = -39;

select sum_mystery_bag_vars ($eeny, $meeny, $miney_mo);

--DORA TIME
-- Set your worksheet drop lists

-- Set these local variables according to the instructions
set this = -10.5;
set that = 2;
set the_other = 1000;
--set the DB and the account
USE ROLE ACCOUNTADMIN;
USE DATABASE UTIL_DB;

-- DO NOT EDIT ANYTHING BELOW THIS LINE
select GRADER(step, (actual = expected), actual, expected, description) as graded_results from (
  SELECT 'DABW006' as step
 ,( select util_db.public.sum_mystery_bag_vars($this,$that,$the_other)) as actual
 , 991.5 as expected
 ,'Mystery Bag Function Output' as description
);

USE ROLE SYSADMIN;

SET alternating_caps_phrase = 'wHy ArE yOu lIkE tHiS?';
create or replace function neutralize_whining ( alternating_caps_phrase TEXT)
    returns TEXT as 'select initcap(alternating_caps_phrase)';
select neutralize_whining('wHy ArE yOu lIkE tHiS?');

--DORA TIME
-- Set your worksheet drop lists
USE ROLE ACCOUNTADMIN;
-- DO NOT EDIT ANYTHING BELOW THIS LINE
select GRADER(step, (actual = expected), actual, expected, description) as graded_results from (
 SELECT 'DABW007' as step
 ,( select hash(neutralize_whining('bUt mOm i wAsHeD tHe dIsHes yEsTeRdAy'))) as actual
 , -4759027801154767056 as expected
 ,'WHINGE UDF Works' as description
);