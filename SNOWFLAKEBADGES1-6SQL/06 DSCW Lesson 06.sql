--Prep environment
USE ROLE SYSADMIN;
USE WAREHOUSE ML_WH;
USE DATABASE CAMILLAS_DB;
CREATE SCHEMA CLASSIFICATION;
USE SCHEMA CLASSIFICATION;

--Create and populate Classification tables
create or replace table camillas_db.classification.train_player_position (
	player_id number(38,0),
	position_code varchar(1),
	game number(38,0),
	minutes_played number(38,0),
	goals number(38,0),
	assists number(38,0),
	shots number(38,0),
	passes number(38,0),
	sprint_distance number(38,0),
	saves number(38,0),
	dribbles number(38,0),
	blocks number(38,0),
	claims number(38,0)
);

--Create stage for file to load
CREATE OR REPLACE STAGE CSV_LOAD ENCRYPTION = (TYPE = 'SNOWFLAKE_FULL') DIRECTORY = (ENABLE = TRUE);

--Create File Format
CREATE OR REPLACE FILE FORMAT FF_STATS_CSV 
    TYPE = CSV,
    SKIP_HEADER = 1,
    FIELD_DELIMITER = ',';

--List the contents of the stage and then examine the file within
list @CAMILLAS_DB.CLASSIFICATION.CSV_LOAD;
select $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13
from @CAMILLAS_DB.CLASSIFICATION.CSV_LOAD/train_player_positions.csv
(file_format => CAMILLAS_DB.CLASSIFICATION.FF_STATS_CSV);

--Copy into section
COPY INTO camillas_db.CLASSIFICATION.train_player_position 
from @CAMILLAS_DB.CLASSIFICATION.CSV_LOAD
files = ('train_player_positions.csv')
FILE_FORMAT =FF_STATS_CSV;

--List contents of newly loaded train_player_position table
select* from camillas_db.CLASSIFICATION.train_player_position;

--Create a table to hold players without positions
create or replace table camillas_db.classification.unclassified_player_positions (
	player_id number(38,0),
	game_id number(38,0),
	mins_played number(38,0),
	goals_made number(38,0),
	assists number(38,0),
	shots number(38,0),
	passes number(38,0),
	sprint_distance number(38,0),
	saves number(38,0),
	dribbles number(38,0),
	blocks number(38,0),
	claims number(38,0)
);

--List the contents of the stage and then examine the file within
list @CAMILLAS_DB.CLASSIFICATION.CSV_LOAD;
select $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12
from @CAMILLAS_DB.CLASSIFICATION.CSV_LOAD/unclassified_player_data.csv
(file_format => CAMILLAS_DB.CLASSIFICATION.FF_STATS_CSV);

--Copy into section
COPY INTO camillas_db.CLASSIFICATION.unclassified_player_positions 
from @CAMILLAS_DB.CLASSIFICATION.CSV_LOAD
files = ('unclassified_player_data.csv')
FILE_FORMAT =FF_STATS_CSV;

--List contents of newly loaded unclassified_player_data table
select* from camillas_db.CLASSIFICATION.unclassified_player_positions;


--DORA Time

-- Set your worksheet drop lists
--This DORA Check Requires that you RUN two Statements, one right after the other
call camillas_db.classification.player_position_classification!SHOW_FEATURE_IMPORTANCE();

--the above command puts information into memory that can be accessed using result_scan(last_query_id())
-- If you have to run this check more than once, always run the LIST command immediately prior
select grader(step, (actual = expected), actual, expected, description) as graded_results from (
 SELECT 'DSCW05' as step
 ,( select count(*) from table(result_scan(last_query_id())) where FEATURE in ('PASSES','MINUTES_PLAYED','DRIBBLES','ASSISTS', 'SAVES', 'CLAIMS')
  ) as actual
 , 6 as expected
 ,'Classification Model Complete' as description
);
