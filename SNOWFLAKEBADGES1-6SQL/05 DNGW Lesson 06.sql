--setup you know and love it
USE ROLE SYSADMIN;
USE DATABASE AGS_GAME_AUDIENCE;
USE SCHEMA RAW;

--create a new stage called uni-kishore-pipeline
CREATE OR ALTER STAGE UNI_KISHORE_PIPELINE 
	URL = 's3://uni-kishore-pipeline';

--check the folder for files
list @UNI_KISHORE_PIPELINE;

--Create the new landing table for this pipeline
CREATE OR REPLACE TABLE PL_GAME_LOGS (
	RAW_LOG VARIANT
);

copy into pl_game_logs from @UNI_KISHORE_PIPELINE file_format = (format_name=FF_JSON_LOGS);
drop task GET_NEW_FILES;
CREATE OR ALTER TASK GET_NEW_FILES
    warehouse = 'COMPUTE_WH'
  as
    copy into pl_game_logs from @UNI_KISHORE_PIPELINE file_format = (format_name=FF_JSON_LOGS);

--EXECUTE new task and wait 10 min then execute again
EXECUTE TASK GET_NEW_FILES;

--CREATE VIEW
create or replace view AGS_GAME_AUDIENCE.RAW.PL_LOGS(
	IP_ADDRESS,
	USER_EVENT,
	USER_LOGIN,
	DATETIME_ISO8601,
	RAWLOG
) as (
    SELECT 
        --RAW_LOG:agent::text as AGENT,
        RAW_LOG:ip_address::text as IP_ADDRESS,
        RAW_LOG:user_event::text as USER_EVENT,
        RAW_LOG:user_login::text as USER_LOGIN,
        RAW_LOG:datetime_iso8601::TIMESTAMP_NTZ as datetime_iso8601,
        --*
        RAW_LOG::VARIANT AS RAWLOG
    FROM PL_GAME_LOGS WHERE RAW_LOG:agent::text IS NULL
);

--test reults
select * from PL_LOGS;

MERGE 
    INTO ENHANCED.LOGS_ENHANCED e
USING (;
    SELECT
        logs.ip_address 
        , r.user_login as GAMER_NAME
        , r.user_event as GAME_EVENT_NAME
        , r.datetime_iso8601 as GAME_EVENT_UTC
        , city
        , region
        , country
        , timezone as GAMER_LTZ_NAME
        , CONVERT_TIMEZONE( 'UTC',timezone,logs.datetime_iso8601) as game_event_ltz
        , DAYNAME(game_event_ltz) as DOW_NAME
        , TOD_NAME
    from 
        ags_game_audience.raw.PL_LOGS logs
        JOIN 
        ipinfo_geoloc.demo.location loc 
        ON ipinfo_geoloc.public.TO_JOIN_KEY(logs.ip_address) = loc.join_key
        AND ipinfo_geoloc.public.TO_INT(logs.ip_address) BETWEEN start_ip_int AND end_ip_int
        JOIN ags_game_audience.raw.TIME_OF_DAY_LU tod
        ON HOUR(game_event_ltz) = tod.hour; r; --as r --we'll put our fancy select here
        on r.gamer_name = e.GAMER_NAME
        and r.game_event_utc = e.game_event_utc
        and r.game_event_name = e.game_event_name
    WHEN NOT MATCHED THEN
insert (IP_ADDRESS, GAMER_NAME, GAME_EVENT_NAME, GAME_EVENT_UTC, CITY, REGION, COUNTRY, GAMER_LTZ_NAME, GAME_EVENT_LTZ, DOW_NAME, TOD_NAME) --list of columns
values (IP_ADDRESS, GAMER_NAME, GAME_EVENT_NAME, GAME_EVENT_UTC, CITY, REGION, COUNTRY, GAMER_LTZ_NAME, GAME_EVENT_LTZ, DOW_NAME, TOD_NAME) --list of columns (but we can mark as coming from the r select)
;

select * from PL_LOGS;

MERGE 
    INTO ENHANCED.LOGS_ENHANCED e
USING (
SELECT
    logs.ip_address,
    logs.USER_LOGIN as GAMER_NAME,
    logs.user_event as GAME_EVENT_NAME,
    logs.datetime_iso8601 as GAME_EVENT_UTC,
    city,
    region,
    country,
    timezone as GAMER_LTZ_NAME,
    CONVERT_TIMEZONE( 'UTC',timezone,logs.datetime_iso8601) as game_event_ltz,
    DAYNAME(game_event_ltz) as DOW_NAME,
    TOD_NAME
from 
    ags_game_audience.raw.PL_LOGS logs
    JOIN 
    ipinfo_geoloc.demo.location loc 
    ON ipinfo_geoloc.public.TO_JOIN_KEY(logs.ip_address) = loc.join_key
    AND ipinfo_geoloc.public.TO_INT(logs.ip_address) BETWEEN start_ip_int AND end_ip_int
    JOIN ags_game_audience.raw.TIME_OF_DAY_LU tod
    ON HOUR(game_event_ltz) = tod.hour)r
ON r.GAMER_NAME = e.GAMER_NAME
and r.game_event_utc = e.game_event_utc
and r.game_event_name = e.game_event_name
WHEN NOT MATCHED THEN
insert (IP_ADDRESS, GAMER_NAME, GAME_EVENT_NAME, GAME_EVENT_UTC, CITY, REGION, COUNTRY, GAMER_LTZ_NAME, GAME_EVENT_LTZ, DOW_NAME, TOD_NAME) --list of columns
values (IP_ADDRESS, GAMER_NAME, GAME_EVENT_NAME, GAME_EVENT_UTC, CITY, REGION, COUNTRY, GAMER_LTZ_NAME, GAME_EVENT_LTZ, DOW_NAME, TOD_NAME) --list of columns (but we can mark as coming from the r select)
;

select * from ENHANCED.LOGS_ENHANCED;
---modify task

create or replace task AGS_GAME_AUDIENCE.RAW.LOAD_LOGS_ENHANCED
	warehouse=COMPUTE_WH
	--schedule='5 minute'
	as MERGE 
    INTO ENHANCED.LOGS_ENHANCED e
USING (
SELECT
    logs.ip_address,
    logs.USER_LOGIN as GAMER_NAME,
    logs.user_event as GAME_EVENT_NAME,
    logs.datetime_iso8601 as GAME_EVENT_UTC,
    city,
    region,
    country,
    timezone as GAMER_LTZ_NAME,
    CONVERT_TIMEZONE( 'UTC',timezone,logs.datetime_iso8601) as game_event_ltz,
    DAYNAME(game_event_ltz) as DOW_NAME,
    TOD_NAME
from 
    ags_game_audience.raw.PL_LOGS logs
    JOIN 
    ipinfo_geoloc.demo.location loc 
    ON ipinfo_geoloc.public.TO_JOIN_KEY(logs.ip_address) = loc.join_key
    AND ipinfo_geoloc.public.TO_INT(logs.ip_address) BETWEEN start_ip_int AND end_ip_int
    JOIN ags_game_audience.raw.TIME_OF_DAY_LU tod
    ON HOUR(game_event_ltz) = tod.hour)r
ON r.GAMER_NAME = e.GAMER_NAME
and r.game_event_utc = e.game_event_utc
and r.game_event_name = e.game_event_name
WHEN NOT MATCHED THEN
insert (IP_ADDRESS, GAMER_NAME, GAME_EVENT_NAME, GAME_EVENT_UTC, CITY, REGION, COUNTRY, GAMER_LTZ_NAME, GAME_EVENT_LTZ, DOW_NAME, TOD_NAME) --list of columns
values (IP_ADDRESS, GAMER_NAME, GAME_EVENT_NAME, GAME_EVENT_UTC, CITY, REGION, COUNTRY, GAMER_LTZ_NAME, GAME_EVENT_LTZ, DOW_NAME, TOD_NAME) --list of columns (but we can mark as coming from the r select)
;

truncate table ENHANCED.LOGS_ENHANCED;
EXECUTE AGS_GAME_AUDIENCE.RAW.LOAD_LOGS_ENHANCED;
----to start or stop automation for the day below
--Turning on a task is done with a RESUME command
alter task AGS_GAME_AUDIENCE.RAW.GET_NEW_FILES resume;
alter task AGS_GAME_AUDIENCE.RAW.LOAD_LOGS_ENHANCED resume;

--Turning OFF a task is done with a SUSPEND command
alter task AGS_GAME_AUDIENCE.RAW.GET_NEW_FILES suspend;
alter task AGS_GAME_AUDIENCE.RAW.LOAD_LOGS_ENHANCED suspend;

SELECT * FROM ENHANCED.LOGS_ENHANCED;

--Step 1 - how many files in the bucket?
list @AGS_GAME_AUDIENCE.RAW.UNI_KISHORE_PIPELINE;

--Step 2 - number of rows in raw table (should be file count x 10)
select count(*) from AGS_GAME_AUDIENCE.RAW.PL_GAME_LOGS;

--Step 3 - number of rows in raw view (should be file count x 10)
select count(*) from AGS_GAME_AUDIENCE.RAW.PL_LOGS;

--Step 4 - number of rows in enhanced table (should be file count x 10 but fewer rows is okay because not all IP addresses are available from the IPInfo share)
select count(*) from AGS_GAME_AUDIENCE.ENHANCED.LOGS_ENHANCED;


 use role accountadmin;
grant EXECUTE MANAGED TASK on account to SYSADMIN;

--switch back to sysadmin
use role sysadmin;

truncate pl_game_logs;

select GRADER(step, (actual = expected), actual, expected, description) as graded_results from
(
SELECT
'DNGW05' as step
 ,(
   select max(tally) from (
       select CASE WHEN SCHEDULED_FROM = 'SCHEDULE' 
                         and STATE= 'SUCCEEDED' 
              THEN 1 ELSE 0 END as tally 
   from table(ags_game_audience.information_schema.task_history (task_name=>'GET_NEW_FILES')))
  ) as actual
 ,1 as expected
 ,'Task succeeds from schedule' as description
 );