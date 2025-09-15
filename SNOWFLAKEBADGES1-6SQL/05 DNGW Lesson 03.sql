--Learn about timestamps and zones

SELECT current_timestamp();

--what time zone is your account(and/or session) currently set to? Is it -0700?
select current_timestamp();

--worksheets are sometimes called sessions -- we'll be changing the worksheet time zone
alter session set timezone = 'UTC';
select current_timestamp();

--how did the time differ after changing the time zone for the worksheet?
alter session set timezone = 'Africa/Nairobi';
select current_timestamp();

alter session set timezone = 'Pacific/Funafuti';
select current_timestamp();

alter session set timezone = 'Asia/Shanghai';
select current_timestamp();

--show the account parameter called timezone
show parameters like 'timezone';

--setup
USE ROLE SYSADMIN;
USE DATABASE AGS_GAME_AUDIENCE;
USE SCHEMA RAW;

--list s3 folders
LIST @uni_kishore/;
LIST @uni_kishore/updated_feed;

--display contents of file, truncate old variant table and reload using new file
SELECT $1 from @uni_kishore/updated_feed (FILE_FORMAT => FF_JSON_LOGS);
TRUNCATE TABLE IF EXISTS GAME_LOGS;
copy into game_logs from @uni_kishore/updated_feed file_format = (format_name=FF_JSON_LOGS);
SELECT 
    RAW_LOG:agent::text as AGENT,
    RAW_LOG:datetime_iso8601::TIMESTAMP_NTZ as datetime_iso8601,
    RAW_LOG:ip_address::TEXT as DUDE,
    RAW_LOG:user_event::text as USER_EVENT,
    RAW_LOG:user_login::text as USER_LOGIN,
    --*
    RAW_LOG::VARIANT AS RAWLOG
FROM GAME_LOGS;
--WHERE AGENT IS NOT NULL;

--two filtering options
--looking for empty AGENT column
select * 
from ags_game_audience.raw.LOGS
where agent is null;

--looking for non-empty IP_ADDRESS column
select 
    --RAW_LOG:ip_address::text as IP_ADDRESS,
    *
from ags_game_audience.raw.LOGS;
where RAW_LOG:ip_address::text is not null;

--Creat a view from new select
CREATE OR REPLACE VIEW LOGS AS (
    SELECT 
        --RAW_LOG:agent::text as AGENT,
        RAW_LOG:datetime_iso8601::TIMESTAMP_NTZ as datetime_iso8601,
        RAW_LOG:ip_address::text as IP_ADDRESS,
        RAW_LOG:user_event::text as USER_EVENT,
        RAW_LOG:user_login::text as USER_LOGIN,
        --*
        RAW_LOG::VARIANT AS RAWLOG
    FROM GAME_LOGS WHERE RAW_LOG:ip_address::text IS NOT NULL
);

--check your work, view now shows the 284 new rows with IP addesses
select * from LOGS;

--find Kishore's sister
select * from LOGS WHERE USER_LOGIN ilike '%prajina%';

--DORA TIME
USE DATABASE UTIL_DB;
select GRADER(step, (actual = expected), actual, expected, description) as graded_results from
(
SELECT
   'DNGW02' as step
   ,( select sum(tally) from(
        select (count(*) * -1) as tally
        from ags_game_audience.raw.logs 
        union all
        select count(*) as tally
        from ags_game_audience.raw.game_logs)     
     ) as actual
   ,250 as expected
   ,'View is filtered' as description
);