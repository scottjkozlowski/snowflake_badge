--Convert regular views to secure views
--Set Role, DB, and Schema
USE ROLE SYSADMIN;
USE DATABASE INTL_DB;

--modify the views here
alter view intl_db.public.NATIONS_SAMPLE_PLUS_ISO
set secure; 

alter view intl_db.public.SIMPLE_CURRENCY
set secure;