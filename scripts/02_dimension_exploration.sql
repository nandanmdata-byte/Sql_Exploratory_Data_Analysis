/*
====================================================================================

-- Dimension Exploration --

Purpose:
	- To explore the structure of dimension tables and
	 extract a unique list of major customer categories for marketing report.

SQL Functions Used:
	- DISTINCT
	- ORDER BY
====================================================================================
*/

-- Retrieve all the different countries the customers come from
SELECT 
	DISTINCT 
	country 
FROM 
gold.dim_customers;

-- Retrieve all unique categories, subcategories and products - "The major divisions"
SELECT DISTINCT 
	category,
	subcategory, 
	product_name 
FROM gold.dim_products
ORDER BY 1,2,3;
