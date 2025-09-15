// JSON DDL Scripts
use database hospital_standard_charges;
use role sysadmin;

// Create an Ingestion Table for JSON Data
create table hospital_standard_charges.public.HOSPITAL_STANDARD_CHARGES_INGEST_JSON
(
  RAW_HOSPITAL_STD_CHGS variant
);

//Create File Format for JSON Data 
create file format hospital_standard_charges.public.json_file_format
type = 'JSON' 
compression = 'AUTO' 
enable_octal = FALSE
allow_duplicate = FALSE 
strip_outer_array = TRUE
strip_null_values = FALSE 
ignore_utf8_errors = FALSE;

--SELECT $1
--FROM @UTIL_DB.PUBLIC.

select $1
from @util_db.public.my_internal_stage/author_with_header.json
(file_format => library_card_catalog.public.JSON_FILE_FORMAT);

copy into author_ingest_json
from @util_db.public.my_internal_stage
files = ( 'author_with_header.json')
file_format = ( format_name=library_card_catalog.public.JSON_FILE_FORMAT );

select * from author_ingest_json;

//returns AUTHOR_UID value from top-level object's attribute
select raw_author:AUTHOR_UID
from author_ingest_json;

//returns the data in a way that makes it look like a normalized table
SELECT 
 raw_author:AUTHOR_UID
,raw_author:FIRST_NAME::STRING as FIRST_NAME
,raw_author:MIDDLE_NAME::STRING as MIDDLE_NAME
,raw_author:LAST_NAME::STRING as LAST_NAME
FROM AUTHOR_INGEST_JSON;
