USE ROLE SYSADMIN;
USE DATABASE ZENAS_ATHLEISURE_DB;
USE SCHEMA PRODUCTS;
LIST @PRODUCT_METADATA;
select $1 from @product_metadata;
select $1 from @product_metadata/product_coordination_suggestions.txt;
select $1 from @product_metadata/sweatsuit_sizes.txt;
select $1 from @product_metadata/swt_product_line.txt;

create or REPLACE file format zmd_file_format_1
RECORD_DELIMITER = ';'
TRIM_SPACE = TRUE;
--FIELD_DELIMITER = ';';

--options to remove LF and CR embedded in columns

create view zenas_athleisure_db.products.sweatsuit_sizes as (
select --$1
REPLACE($1, chr(13)||char(10)) as sizes_available
from @product_metadata/sweatsuit_sizes.txt
(file_format => zmd_file_format_1)
WHERE sizes_available <>'');

/*You could use: 

REPLACE($1, concat(chr(13),chr(10)))

Or you could use: 

REPLACE($1, '\r\n')
from @product_metadata/sweatsuit_sizes.txt
(file_format => zmd_file_format_1);
*/
create or replace file format zmd_file_format_2
FIELD_DELIMITER = '|', record_delimiter = ';',
TRIM_SPACE = TRUE;  

create OR REPLACE view zenas_athleisure_db.products.SWEATBAND_PRODUCT_LINE as (select 
REPLACE($1, chr(13)||char(10)) as PRODUCT_CODE,
REPLACE($2, chr(13)||char(10)) as HEADBAND_DESCRIPTION,
REPLACE($3, chr(13)||char(10)) as WRISTBAND_DESCRIPTION
from @product_metadata/swt_product_line.txt
(file_format => zmd_file_format_2));

create or replace file format zmd_file_format_3
FIELD_DELIMITER = '='
RECORD_DELIMITER = '^'
TRIM_SPACE = TRUE; 

CREATE OR REPLACE VIEW SWEATBAND_COORDINATION AS (
select $1 AS PRODUCT_CODE, $2 AS HAS_MATCHING_SWEATSUIT
from @product_metadata/product_coordination_suggestions.txt
(file_format => zmd_file_format_3));

select * from sweatsuit_sizes;
select * from SWEATBAND_PRODUCT_LINE;
select * from SWEATBAND_COORDINATION;

--DORA time
USE ROLE ACCOUNTADMIN;
USE DATABASE UTIL_DB;

select GRADER(step, (actual = expected), actual, expected, description) as graded_results from
(
 SELECT
   'DLKW02' as step
   ,( select sum(tally) from
        ( select count(*) as tally
        from ZENAS_ATHLEISURE_DB.PRODUCTS.SWEATBAND_PRODUCT_LINE
        where length(product_code) > 7 
        union
        select count(*) as tally
        from ZENAS_ATHLEISURE_DB.PRODUCTS.SWEATSUIT_SIZES
        where LEFT(sizes_available,2) = char(13)||char(10))     
     ) as actual
   ,0 as expected
   ,'Leave data where it lands.' as description
);

--Set back
USE ROLE SYSADMIN;
USE DATABASE ZENAS_ATHLEISURE_DB;
USE SCHEMA PRODUCTS;

select product_code, has_matching_sweatsuit
from zenas_athleisure_db.products.sweatband_coordination;

select product_code, headband_description, wristband_description
from zenas_athleisure_db.products.sweatband_product_line;

select sizes_available
from zenas_athleisure_db.products.sweatsuit_sizes;