/*
===============================================================================

-- Date Exploration --

Purpose:
	- To establish the operational timeframe of the sales lifecycle.
	- To define the demographic age range of the current customer base for targeted marketing.

SQL Functions Used:
    - MIN(), MAX(), DATEDIFF()

===============================================================================
*/
-- Find the date of the first and last order
-- Find the total duration between first and last order in months
SELECT 
	MIN(order_date) AS first_order,
	MAX(order_date) AS last_order,
	DATEDIFF(MONTH,MIN(order_date),MAX(order_date)) AS order_range_months
FROM gold.fact_sales;

-- Based on their birthdate, find the youngest and oldest customer

SELECT 
	MIN(birthdate) AS oldest_birthdate,
	DATEDIFF(year,MIN(birthdate),GETDATE()) AS oldest_age,
	MAX(birthdate) AS youngest_birthdate,
	DATEDIFF(year,MAX(birthdate),GETDATE()) AS youngest_age
FROM gold.dim_customers;
