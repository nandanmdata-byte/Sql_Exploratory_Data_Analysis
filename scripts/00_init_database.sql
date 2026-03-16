/*
==============================================================================

| Create Database and Schemas |

==============================================================================
Purpose:
    The following script ensures a fresh start for the 'DataWarehouseAnalytics' environment
	by removing any existing version of the database before recreating it.
	It also initializes a new 'gold' schema after recreating the database.

	
WARNING:
    Executing this script will permanently delete the 'DataWarehouseAnalytics' database and all its contents
	( including VIEWS and other objects). 
	Please verify that you have current backups and proceed with care, as this action cannot be undone.
*/

USE master;
GO

-- Drop and recreate the datawarehouse 'DataWarehouse_Analaytics'
IF EXISTS ( SELECT name FROM sys.databases WHERE name = 'DataWarehouse_Analytics')
BEGIN
	ALTER DATABASE DataWarehouse_Analytics SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE DataWarehouse_Analytics;
	PRINT 'Database Dropped.';
END;
GO

-- Create brand new database 'DataWarehouseAnalytics'
CREATE DATABASE DataWarehouse_Analytics;
GO

USE DataWarehouse_Analytics;
GO

-- create 'gold' schema
CREATE SCHEMA gold;
GO

-- Create tables in 'gold' schema
IF OBJECT_ID('gold.dim_customers','U') IS NOT NULL
BEGIN 
	DROP TABLE gold.dim_customers
END;
GO
CREATE TABLE gold.dim_customers (
	customer_key INT,
	customer_id INT,
	customer_number NVARCHAR(50),
	first_name NVARCHAR(50),
	last_name NVARCHAR(50),
	country NVARCHAR(50),
	marital_status NVARCHAR(50),
	gender NVARCHAR(50),
	birthdate DATE,
	create_date DATE
);
GO

IF OBJECT_ID('gold.dim_products','U') IS NOT NULL
BEGIN 
	DROP TABLE gold.dim_products
END;
GO
CREATE TABLE gold.dim_products (
	product_key INT ,
	product_id INT ,
	product_number NVARCHAR(50) ,
	product_name NVARCHAR(50) ,
	category_id NVARCHAR(50) ,
	category NVARCHAR(50) ,
	subcategory NVARCHAR(50) ,
	maintenance NVARCHAR(50) ,
	cost INT,
	product_line NVARCHAR(50),
	start_date DATE 
);
GO

IF OBJECT_ID('gold.fact_sales','U') IS NOT NULL
BEGIN 
	DROP TABLE gold.fact_sales
END;
GO
CREATE TABLE gold.fact_sales(
	order_number NVARCHAR(50),
	product_key INT,
	customer_key INT,
	order_date DATE,
	shipping_date DATE,
	due_date DATE,
	sales_amount INT,
	quantity TINYINT,
	price INT 
);
GO

-- FULL LOAD ( TRUNCATE & INSERT ) to the tables

-- ---------------------------------------------------------
-- DATA INSERT -  gold.dim_customers Table
-- ---------------------------------------------------------
TRUNCATE TABLE gold.dim_customers;
GO
PRINT '>>> Inserting data into gold.dim_customers';
BULK INSERT gold.dim_customers
FROM 'C:\My_Projects\Sql_Exploratory_Data_Analysis\datasets\flat_files\dim_customers.csv'
WITH(
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	TABLOCK
);
GO

-- ---------------------------------------------------------
-- DATA INSERT -  gold.dim_products Table
-- ---------------------------------------------------------
TRUNCATE TABLE gold.dim_products;
GO
PRINT '>>> Inserting data into gold.dim_products';
BULK INSERT gold.dim_products
FROM 'C:\My_Projects\Sql_Exploratory_Data_Analysis\datasets\flat_files\dim_products.csv'
WITH(
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	TABLOCK
);
GO
	
-- ---------------------------------------------------------
-- DATA INSERT -  gold.fact_sales Table
-- ---------------------------------------------------------

TRUNCATE TABLE gold.fact_sales;
GO
PRINT '>>> Inserting data into gold.fact_sales';
BULK INSERT gold.fact_sales
FROM 'C:\My_Projects\Sql_Exploratory_Data_Analysis\datasets\flat_files\fact_sales.csv'
WITH(
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	TABLOCK
);
GO
