USE ROLE SYSADMIN;
CREATE OR REPLACE DATABASE ZENAS_ATHLEISURE_DB COMMENT = 'POC DB';
USE DATABASE ZENAS_ATHLEISURE_DB;
DROP SCHEMA PUBLIC;
CREATE OR REPLACE SCHEMA PRODUCTS;
USE SCHEMA PRODUCTS;
CREATE OR ALTER STAGE SWEATSUITS
ENCRYPTION = ( TYPE = 'SNOWFLAKE_SSE' );
CREATE OR ALTER STAGE PRODUCT_METADATA
ENCRYPTION = ( TYPE = 'SNOWFLAKE_FULL' );

--DORA TIME
USE ROLE ACCOUNTADMIN;
USE DATABASE UTIL_DB;
select GRADER(step, (actual = expected), actual, expected, description) as graded_results from
(
 SELECT
 'DLKW01' as step
  ,( select count(*)  
      from ZENAS_ATHLEISURE_DB.INFORMATION_SCHEMA.STAGES 
      where stage_schema = 'PRODUCTS'
      and 
      (stage_type = 'Internal Named' 
      and stage_name = ('PRODUCT_METADATA'))
      or stage_name = ('SWEATSUITS')
   ) as actual
, 2 as expected
, 'Zena stages look good' as description
);

USE ROLE SYSADMIN;
USE DATABASE ZENAS_ATHLEISURE_DB;

--3 structural data types
--ARRAY, OBJECT, and MAP
--5 semi-structered data typesSnowflake can load into VARIANT columns
--a variant can store a value of any other type including semi structered types 
/*
Summary of data types
Snowflake supports most SQL data types. The following table provides a summary of the supported data types.
Category
Type
Notes
Numeric data types
NUMBER
Default precision and scale are (38,0).
DECIMAL, NUMERIC
Synonymous with NUMBER.
INT, INTEGER, BIGINT, SMALLINT, TINYINT, BYTEINT
Synonymous with NUMBER, except precision and scale can’t be specified.
FLOAT, FLOAT4, FLOAT8
[1]
DOUBLE, DOUBLE PRECISION, REAL
Synonymous with FLOAT. [1]
String & binary data types
VARCHAR
Default length is 16777216 bytes. Maximum length is 134217728 bytes.
CHAR, CHARACTER
Synonymous with VARCHAR, except the default length is VARCHAR(1).
STRING, TEXT
Synonymous with VARCHAR.
BINARY
VARBINARY
Synonymous with BINARY.
Logical data types
BOOLEAN
Currently only supported for accounts provisioned after January 25, 2016.
Date & time data types
DATE
DATETIME
Alias for TIMESTAMP_NTZ
TIME
TIMESTAMP
Alias for one of the TIMESTAMP variations (TIMESTAMP_NTZ by default).
TIMESTAMP_LTZ
TIMESTAMP with local time zone; time zone, if provided, isn’t stored.
TIMESTAMP_NTZ
TIMESTAMP with no time zone; time zone, if provided, isn’t stored.
TIMESTAMP_TZ
TIMESTAMP with time zone.
Semi-structured data types
VARIANT
OBJECT
ARRAY
Structured data types
ARRAY
Currently only supported for Iceberg tables.
OBJECT
Currently only supported for Iceberg tables.
MAP
Currently only supported for Iceberg tables.
Unstructured data types
FILE
See Introduction to unstructured data
Geospatial data types
GEOGRAPHY
GEOMETRY
Vector data types
VECTOR */