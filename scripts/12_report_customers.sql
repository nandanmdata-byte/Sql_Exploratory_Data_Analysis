/*
========================================================================================

CUSTOMER REPORT

========================================================================================

Purpose:
	- Provides a unified view of customer engagement, metrics and purchasing patterns.

Key Features:
	1. Captures core profile data fields such as names, ages, and transactional details.
	2. Tiered Classification: Groups customers into categories ( VIP, Regular, New) and age groups.
	3. Aggregates customer - level performance metrics:
		Computes high - level total measures such as
		- total sales
		- total orders
		- total products
		- total quantity purchased
		- lifespan ( in months )
	4. Calculates valuable KPIs:
		- recency ( months since last order )
		- average monthly spend
		- average order value

========================================================================================
*/

IF OBJECT_ID('gold.report_customers', 'V') IS NOT NULL
	DROP VIEW gold.report_customers;

GO

CREATE VIEW gold.report_customers AS
WITH base_query AS (
/*
----------------------------------------------------------------------------------------------------
1) Base Query: Retrieves core columns from tables
----------------------------------------------------------------------------------------------------
*/
SELECT
	f.order_number,
	f.order_date,
	f.product_key,
	f.sales_amount,
	f.quantity,
	c.customer_key,
	c.customer_number,
	CONCAT(c.first_name,' ',c.last_name) AS customer_name,
	DATEDIFF(year, c.birthdate, GETDATE()) AS age
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
	ON f.customer_key = c.customer_key
WHERE f.order_date IS NOT NULL
),
customer_aggregations AS (
/*
----------------------------------------------------------------------------------------------------
2) Customer Aggregations Query: Aggregates key metrics at customer level for a comprehensive view
----------------------------------------------------------------------------------------------------
*/
SELECT
	customer_key,
	customer_number,
	customer_name,
	age,
	COUNT(DISTINCT order_number) AS total_orders,
	SUM(sales_amount) AS total_sales,
	SUM(quantity) AS total_quantity,
	COUNT(DISTINCT product_key) AS total_products,
	MIN(order_date) AS first_order_date,
	MAX(order_date) AS last_order_date,
	DATEDIFF(month, MIN(order_date), MAX(order_date)) AS lifespan	
FROM base_query
GROUP BY 
	customer_key,
	customer_number, 
	customer_name, 
	age
)
/*
----------------------------------------------------------------------------------------
3) Final Query: Combine all the customer results into one final output
----------------------------------------------------------------------------------------
*/

SELECT
	customer_key,
	customer_number, 
	customer_name, 
	age,
	-- Customer segmentation based on age
	CASE
		WHEN age < 20 THEN 'Under 20'
		WHEN age BETWEEN 20 AND 29 THEN '20 - 29'
		WHEN age BETWEEN 30 AND 39 THEN '30 - 39'
		WHEN age BETWEEN 40 AND 49 THEN '40 - 49'
		ELSE ' 50 and above'
	END AS age_group,
	lifespan,
	first_order_date,
	last_order_date,
	DATEDIFF(month, last_order_date, GETDATE()) AS recency_in_months,
	-- Customer segmentation based on total sales and lifespan
	CASE 
		WHEN lifespan >= 12 AND total_sales > 5000 THEN ' VIP'
		WHEN lifespan >= 12 AND total_sales <= 5000 THEN ' Regular'
		ELSE ' New'
	END AS customer_segments,
	total_orders,
	total_quantity,
	total_products,
	total_sales,
	-- Compute the average order value ( AVO )
	CASE 
		WHEN total_orders = 0 THEN 0
		ELSE total_sales/total_orders 
	END AS avg_order_value,
	-- Compute average monthly spend
	CASE
		WHEN lifespan = 0 THEN total_sales
		ELSE total_sales/lifespan 
	END AS avg_monthly_spend
FROM customer_aggregations