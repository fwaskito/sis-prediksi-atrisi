/*
* Author		: F. Waskito
* Create on 	: Sat 03 Dec 2022
* Document  	: SQL syntax for get and basic information about database
* DBMS			: MySQL
* Server Version: 8.0.31-0ubuntu0.22.04.1 (Ubuntu) 
*/

show tables;
desc department;
desc employee;
desc employee_history;
desc user;
/*==============================================================
Display existing constraints.
---------------------------------------------------------------*/
SELECT table_name,
	   column_name,
       constraint_name,
       referenced_table_name,
       referenced_column_name
FROM  information_schema.key_column_usage
WHERE referenced_table_schema = 'sppk';

SELECT table_name, 
	   constraint_type, 
       constraint_name
FROM information_schema.table_constraints
WHERE table_schema = 'sppk';

/*==============================================================
Display existing triggers.
---------------------------------------------------------------*/
SHOW triggers IN sppk;

SELECT trigger_schema,
	   trigger_name,
       event_manipulation,
       event_object_schema,
       event_object_table,
       action_orientation,
       action_timing
FROM information_schema.triggers
WHERE trigger_schema = 'sppk';

SELECT trigger_schema,
	   trigger_name,
       event_manipulation,
       event_object_schema,
       event_object_table,
       action_orientation,
       action_timing,
       action_reference_old_table,
       action_reference_new_table,
       created,
       definer,
       character_set_client,
       collation_connection,
       database_collation
FROM information_schema.triggers
WHERE trigger_schema = 'sppk';
       
/*==============================================================
Displays the entire value set in mysql.
----------------------------------------------------------------*/
SHOW variables;

SHOW variables
LIKE '%default%';

/*==============================================================
Display the value of the character set and collation.
----------------------------------------------------------------*/
SHOW variables 
LIKE '%character%';

SHOW character set 
WHERE charset = 'utf8mb4';

SHOW variables
LIKE '%collation%';

SHOW SESSION VARIABLES LIKE 'character\_set\_%';

SHOW SESSION VARIABLES LIKE 'collation_connection';

SET collation_connection = 'utf8mb4_0900_ai_ci';
SET collation_server = 'utf8mb4_general_ci';
SET default_collation_for_utf8mb4 = 'utf8mb4_general_ci';

SET NAMES 'utf8mb4' COLLATE 'utf8mb4_0900_ai_ci';

SELECT SCHEMA_NAME,
DEFAULT_CHARACTER_SET_NAME,
DEFAULT_COLLATION_NAME
FROM INFORMATION_SCHEMA.SCHEMATA
WHERE SCHEMA_NAME='sppk';

ALTER DATABASE sppk
CHARACTER SET utf8mb4
COLLATE utf8mb4_0900_ai_ci;

ALTER TABLE employee
CHARACTER SET utf8mb4 
COLLATE utf8mb4_general_ci;

SELECT TABLE_NAME, 
	   COLUMN_NAME, 
       COLLATION_NAME 
FROM INFORMATION_SCHEMA.COLUMNS
WHERE table_schema = 'sppk' and
TABLE_NAME = 'department';

/*==============================================================
Display important information of existing tables.
----------------------------------------------------------------*/
SHOW table status
FROM sppk;

SELECT table_name,
       table_type,
       engine,
       version,
       row_format,
       table_rows,
       avg_row_length,
       data_length,
       max_data_length,
       index_length,
       data_free,
       auto_increment,
       create_time,
       update_time,
       check_time,
       table_collation,
       checksum,
       create_options,
       table_comment
FROM information_schema.tables
WHERE table_schema = 'sppk';

/*==============================================================
Displays availabe and used engines.
---------------------------------------------------------------*/
SHOW engines;

SELECT table_name, 
	   engine
FROM information_schema.tables
WHERE table_schema = 'sppk';

