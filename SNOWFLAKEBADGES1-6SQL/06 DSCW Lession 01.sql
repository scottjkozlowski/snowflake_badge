
alter user SKSNOWFLAKE01 set default_role = 'SYSADMIN';
alter user SKSNOWFLAKE01 set default_warehouse = 'COMPUTE_WH';
alter user SKSNOWFLAKE01 set default_namespace = 'UTIL_DB.PUBLIC';

select util_db.public.grader(step, (actual = expected), actual, expected, description) as graded_results from
(SELECT 
 'DORA_IS_WORKING' as step
 ,(select 123 ) as actual
 ,123 as expected
 ,'Dora is working!' as description
); 