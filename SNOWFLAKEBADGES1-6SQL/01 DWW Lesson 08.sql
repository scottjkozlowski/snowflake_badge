--Notebooks and forms using Streamlit in Snowflake forms

--get this from existing table description
create or replace TABLE GARDEN_PLANTS.VEGGIES.VEGETABLE_DETAILS (
PLANT_NAME VARCHAR (25) .
ROOT_DEPTH_CODE VARCHAR (1)
) ;

--Replace GARDEN_PLANTS.VEGGIES.VEGETABLE with GARDERN_PLANTS.FLOWERS.FLOWER_DETAILS
create or replace TABLE GARDEN_PLANTS.FLOWERS.FLOWER_DETAILS (
PLANT_NAME VARCHAR (25) .
ROOT_DEPTH_CODE VARCHAR (1)
) ;

--Notebooks are vertical stacks of named cells which support
--SQL, PYTHON, or MARKDOWN

-- code added to SQL cell
insert into garden_plants.flowers.flower_details
select 'Petunia','M';

--create second SQL cell
Select * from GARDEN_PLANTS.FLOWERS.FLOWER_DETAILS;

--create 3 more SQ: cells containing the following 1 line per cell
set rdc = 'S';
set fn = 'Lilac';
select $fn, $rdc;

--Create SQL cell and add the following code
insert into garden_plants.flowers.flower_details
select
$fn, Srdc;

--add 1 more SQL cell with the following
select *
from garden_plants.flowers.flower_details;

--modify the markdown cell as follows
# Add Rows to Flower Detail Table Edit the "set" cells to update the variables, then click "Run All"
in the top left-corner.

--Potential clean up SQL if needed
delete from garden_plants.flowers.flower_details
where plant_name = 'Sunflower'
and root_depth_code = 'S';

--DORA code to verify chapter 8
--Set your worksheet drop list role to ACCOUNTADMIN
--Set your worksheet drop list database and schema to the location of your GRADER function

-- DO NOT EDIT ANYTHING BELOW THIS LINE. THE CODE MUST BE RUN EXACTLY AS IT IS WRITTEN
select GRADER(step, (actual = expected), actual, expected, description) as graded_results from ( 
   SELECT 'DWW08' as step 
   ,( select iff(count(*)=0, 0, count(*)/count(*))
      from table(information_schema.query_history())
      where query_text like 'execute notebook%Uncle Yer%') as actual 
   , 1 as expected 
   , 'Notebook success!' as description 
);

--Edit form title and instruction line below is python streamlit code
# Import python packages import streamlit as st
from snowflake.snowpark.context import get_active_sessic
# Write directly to the app
st.title(":apple: Uncle Yer's Fruit Details : apple:"›
st-writel
•""Enter fruit name and root depth code below.
# Get the current credentials
session = get_active_session()

--Add input fields thus
st.text_input('Fruit Name:')
st.selectbox('Root Depth:', ('S','M','D'))

--ini streamlit use the following to set variables
fn =st. text_input ( 'Fruit Name:')
rdc =st. selectbox ('Root Depth:', ('S', 'M', 'D'))

--add a submit button
if st.button('Submit'):
    st.write('Fruit Name entered is ' + fn)
    st.write('Root Depth Code chosen is ' + rdc)
    sql_insert = 'insert into garden_plants.fruits.fruit_details select \''+fn+'\',\''+rdc+'\''
    #st.write(sql_insert)
    result = session.sql(sql_insert)
    st.write(result)

--then add # to comment out the following lines
    #st.write('Fruit Name entered is ' + fn)
    #st.write('Root Depth Code chosen is ' + rdc)

--DORA check code
--Set your worksheet drop list role to ACCOUNTADMIN
--Set your worksheet drop list database and schema to the location of your GRADER function

-- DO NOT EDIT ANYTHING BELOW THIS LINE. THE CODE MUST BE RUN EXACTLY AS IT IS WRITTEN
select GRADER(step, (actual = expected), actual, expected, description) as graded_results from (
 SELECT 'DWW09' as step
 ,( select iff(count(*)=0, 0, count(*)/count(*)) 
    from snowflake.account_usage.query_history
    where query_text like 'execute streamlit "GARDEN_PLANTS"."FRUITS".%'
   ) as actual
 , 1 as expected
 ,'SiS App Works' as description
);