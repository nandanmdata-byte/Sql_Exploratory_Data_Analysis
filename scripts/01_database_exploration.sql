/*
===============================================================================

| DATABASE EXPLORATION |

===============================================================================
Purpose:
    - To explore the structure of the database, including the list of tables and their schemas.
    - To inspect metadata about the columns and specific tables.

Table Used:
    - INFORMATION_SCHEMA.TABLES
    - INFORMATION_SCHEMA.COLUMNS
===============================================================================
*/

-- Generate a comprehensive inventory of all user-defined tables.
USE DataWarehouse_Analytics;
GO

SELECT
	TABLE_CATALOG,
	TABLE_NAME,
	TABLE_SCHEMA,
	TABLE_TYPE
FROM INFORMATION_SCHEMA.TABLES;

-- Inspect column definitions and data types for a specific table.
SELECT
	COLUMN_NAME,
	DATA_TYPE,
	IS_NULLABLE,
	CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'dim_customers';

