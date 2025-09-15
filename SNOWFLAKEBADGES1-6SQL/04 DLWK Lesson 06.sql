USE ROLE SYSADMIN;
-- SET THE STAGE
USE DATABASE MELS_SMOOTHIE_CHALLENGE_DB;
USE SCHEMA TRAILS;

--VIEW THE DATA
SELECT * FROM @TRAILS_PARQUET (FILE_FORMAT => FF_PARQUET);

--SEPERATE THE COLUMNS, REORDER AND SORT
SELECT 
    $1:sequence_1::NUMBER as sequence_1,
    $1:trail_name::VARCHAR as trail_name,
    $1:latitude as latitude,
    $1:longitude as longitude,
    $1:sequence_2 as sequence_2,
    $1:elevation as elevation
FROM 
@TRAILS_PARQUET
(FILE_FORMAT => FF_PARQUET)
order by sequence_1; 

--FINALLY SOME LAST FORMATTING CHANGES
--Nicely formatted trail data
select 
 $1:sequence_1::NUMBER as point_id,
 $1:trail_name::varchar as trail_name,
 $1:latitude::number(11,8) as lng, --remember we did a gut check on this data
 $1:longitude::number(11,8) as lat
from @trails_parquet
(file_format => ff_parquet)
order by point_id;

--JUST CHERRY CREEK TRAIL
select 
 $1:sequence_1::NUMBER as point_id,
 $1:trail_name::varchar as trail_name,
 $1:latitude::number(11,8) as lng, --remember we did a gut check on this data
 $1:longitude::number(11,8) as lat
from @trails_parquet
(file_format => ff_parquet)
WHERE point_id = 1;

--CREATE A POINT STRING
select
 'POINT('||TO_VARCHAR($1:latitude::number(11,8)) ||
 ' '|| --remember we did a gut check on this data
 TO_VARCHAR($1:longitude::number(11,8))||')' as USE_ME
from @trails_parquet
(file_format => ff_parquet)
WHERE $1:sequence_1::NUMBER = 1;

--CREATE A VIEW OF EARLIER QUERY
CREATE OR REPLACE VIEW CHERRY_CREEK_TRAIL AS (
select 
 $1:sequence_1::NUMBER as point_id,
 $1:trail_name::varchar as trail_name,
 $1:latitude::number(11,8) as lng, --remember we did a gut check on this data
 $1:longitude::number(11,8) as lat
from @trails_parquet
(file_format => ff_parquet)
--WHERE point_id = 1
);

select * from CHERRY_CREEK_TRAIL;

--Using concatenate to prepare the data for plotting on a map
select top 100 
 lng||' '||lat as coord_pair
,'POINT('||coord_pair||')' as trail_point
from cherry_creek_trail;

--To add a column, we have to replace the entire view
--changes to the original are shown in red
create or replace view cherry_creek_trail as
select 
 $1:sequence_1 as point_id,
 $1:trail_name::varchar as trail_name,
 $1:latitude::number(11,8) as lng,
 $1:longitude::number(11,8) as lat,
 lng||' '||lat as coord_pair
from @trails_parquet
(file_format => ff_parquet)
order by point_id;

--next create a resultset for a linestring
select 
'LINESTRING('||
listagg(coord_pair, ',') 
within group (order by point_id)
||')' as my_linestring
from cherry_creek_trail
where point_id <= 2450 --10
group by trail_name;

select * from @trails_geojson
(file_format => ff_json);

--Next step
select
$1:features[0]:properties:Name::string as feature_name
,$1:features[0]:geometry:coordinates::string as feature_coordinates
,$1:features[0]:geometry::string as geometry
,$1:features[0]:properties::string as feature_properties
,$1:crs:properties:name::string as specs
,$1 as whole_object
from @trails_geojson (file_format => ff_json);

-- then create a view from it
CREATE OR REPLACE VIEW DENVER_AREA_TRAILS AS (
select
$1:features[0]:properties:Name::string as feature_name
,$1:features[0]:geometry:coordinates::string as feature_coordinates
,$1:features[0]:geometry::string as geometry
,$1:features[0]:properties::string as feature_properties
,$1:crs:properties:name::string as specs
,$1 as whole_object
from @trails_geojson (file_format => ff_json)
);

-- DORA TIME
USE ROLE ACCOUNTADMIN;
USE DATABASE UTIL_DB;

select GRADER(step, (actual = expected), actual, expected, description) as graded_results from
(
SELECT
'DLKW06' as step
 ,( select count(*) as tally
      from mels_smoothie_challenge_db.information_schema.views 
      where table_name in ('CHERRY_CREEK_TRAIL','DENVER_AREA_TRAILS')) as actual
 ,2 as expected
 ,'Mel\'s views on the geospatial data from Camila' as description
 );