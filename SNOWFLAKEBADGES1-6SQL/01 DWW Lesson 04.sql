--Be sure to set your context menus
USE ROLE SYSADMIN;
USE DATABASE GARDEN_PLANTS;
USE SCHEMA VEGGIES;
create or replace table ROOT_DEPTH (
   ROOT_DEPTH_ID number(1), 
   ROOT_DEPTH_CODE text(1), 
   ROOT_DEPTH_NAME text(7), 
   UNIT_OF_MEASURE text(2),
   RANGE_MIN number(2),
   RANGE_MAX number(2)
   );
--Insert singular row into ROOT_DEPTH table using hard coded values
insert into root_depth 
values
(
    1,
    'S',
    'Shallow',
    'cm',
    30,
    45
)
;

-- Using the LIMIT statement helps to constrain rows returned from a big query
SELECT *
FROM ROOT_DEPTH
LIMIT 1;

-- SAMPLE CODE DON'T RUN
--THESE ARE JUST EXAMPLES YOU SHOULD NOT RUN THIS CODE WITHOUT EDITING IT FOR YOUR NEEDS

--To add more than one row at a time
insert into root_depth (root_depth_id, root_depth_code
                        , root_depth_name, unit_of_measure
                        , range_min, range_max)  
values
                        (5,'X','short','in',66,77)
                       ,(8,'Y','tall','cm',98,99)
;

-- To remove a row you do not want in the table
delete from root_depth
where root_depth_id = 9;

--To change a value in a column for one particular row
update root_depth
set root_depth_id = 7
where root_depth_id = 9;

--To remove all the rows and start over
truncate table root_depth;