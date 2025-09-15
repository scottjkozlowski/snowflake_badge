--SET THING UP
USE ROLE SYSADMIN;
USE DATABASE ZENAS_ATHLEISURE_DB;
USE SCHEMA PRODUCTS;
LIST @SWEATSUITS;

select $1
from @sweatsuits/purple_sweatsuit.png;

select metadata$filename, metadata$file_row_number
from @sweatsuits/purple_sweatsuit.png;

select metadata$filename, MAX(metadata$file_row_number)
from @sweatsuits
GROUP BY METADATA$FILENAME;

select * 
from directory(@sweatsuits);

--notice below that you can use a function on a column as "name" immediately after creating it, woah!
select REPLACE(relative_path, '_', ' ') as no_underscores_filename
, REPLACE(no_underscores_filename, '.png') as just_words_filename
, INITCAP(just_words_filename) as product_name
from directory(@sweatsuits);

--nest things up!
select INITCAP(REPLACE(REPLACE(relative_path, '_', ' '), '.png')) as PRODUCT_NAME
from directory(@sweatsuits);

--create an internal table for some sweatsuit info
create or replace table zenas_athleisure_db.products.sweatsuits (
	color_or_style varchar(25),
	file_name varchar(50),
	price number(5,2)
);

--fill the new table with some data
insert into  zenas_athleisure_db.products.sweatsuits 
          (color_or_style, file_name, price)
values
 ('Burgundy', 'burgundy_sweatsuit.png',65)
,('Charcoal Grey', 'charcoal_grey_sweatsuit.png',65)
,('Forest Green', 'forest_green_sweatsuit.png',64)
,('Navy Blue', 'navy_blue_sweatsuit.png',65)
,('Orange', 'orange_sweatsuit.png',65)
,('Pink', 'pink_sweatsuit.png',63)
,('Purple', 'purple_sweatsuit.png',64)
,('Red', 'red_sweatsuit.png',68)
,('Royal Blue',	'royal_blue_sweatsuit.png',65)
,('Yellow', 'yellow_sweatsuit.png',67);

--now lets join a table we just created and populated in snowflake with a directory table
select INITCAP(REPLACE(REPLACE(relative_path, '_', ' '), '.png')) as PRODUCT_NAME,
    * from  directory(@sweatsuits) join sweatsuits ON relative_path = SWEATSUITS.FILE_NAME ;

--and then we'll create a view
CREATE OR REPLACE VIEW PRODUCT_LIST AS (
    select 
        INITCAP(REPLACE(REPLACE(relative_path, '_', ' '), '.png')) as PRODUCT_NAME,
        FILE_NAME,
        COLOR_OR_STYLE,
        PRICE,
        FILE_URL
    from 
        directory(@sweatsuits) 
        join 
        sweatsuits 
        ON relative_path = SWEATSUITS.FILE_NAME
);

--Lets try a cross join like so
select * 
from product_list p
cross join sweatsuit_sizes;

-- turn the above into another view
CREATE OR REPLACE VIEW CATALOG as (select * 
from product_list p
cross join sweatsuit_sizes);

--DORA TIME
USE ROLE ACCOUNTADMIN;
USE DATABASE  UTIL_DB;
USE SCHEMA PUBLIC;

--DORA CODE HERE
select GRADER(step, (actual = expected), actual, expected, description) as graded_results from
(
 SELECT
 'DLKW03' as step
 ,( select count(*) from ZENAS_ATHLEISURE_DB.PRODUCTS.CATALOG) as actual
 ,180 as expected
 ,'Cross-joined view exists' as description
); 


--reset rolse db and schema and continue
USE ROLE SYSADMIN;
USE DATABASE ZENAS_ATHLEISURE_DB;
USE SCHEMA PRODUCTS;

-- Add a table to map the sweatsuits to the sweat band sets
create table zenas_athleisure_db.products.upsell_mapping
(
sweatsuit_color_or_style varchar(25)
,upsell_product_code varchar(10)
);

--populate the upsell table
insert into zenas_athleisure_db.products.upsell_mapping
(
sweatsuit_color_or_style
,upsell_product_code 
)
VALUES
('Charcoal Grey','SWT_GRY')
,('Forest Green','SWT_FGN')
,('Orange','SWT_ORG')
,('Pink', 'SWT_PNK')
,('Red','SWT_RED')
,('Yellow', 'SWT_YLW');

-- Zena needs a single view she can query for her website prototype
create view catalog_for_website as 
select color_or_style
,price
,file_name
, get_presigned_url(@sweatsuits, file_name, 3600) as file_url
,size_list
,coalesce('Consider: ' ||  headband_description || ' & ' || wristband_description, 'Consider: White, Black or Grey Sweat Accessories')  as upsell_product_desc
from
(   select color_or_style, price, file_name
    ,listagg(sizes_available, ' | ') within group (order by sizes_available) as size_list
    from catalog
    group by color_or_style, price, file_name
) c
left join upsell_mapping u
on u.sweatsuit_color_or_style = c.color_or_style
left join sweatband_coordination sc
on sc.product_code = u.upsell_product_code
left join sweatband_product_line spl
on spl.product_code = sc.product_code;

--DORA TIME
USE ROLE ACCOUNTADMIN;
USE DATABASE  UTIL_DB;
USE SCHEMA PUBLIC;

select GRADER(step, (actual = expected), actual, expected, description) as graded_results from
(
SELECT
'DLKW04' as step
 ,( select count(*) 
  from zenas_athleisure_db.products.catalog_for_website 
  where upsell_product_desc not like '%e, Bl%') as actual
 ,6 as expected
 ,'Relentlessly resourceful' as description
);

--reset rolse db and schema and continue
USE ROLE SYSADMIN;
USE DATABASE ZENAS_ATHLEISURE_DB;
USE SCHEMA PRODUCTS;
