/*
===============================================================================

-- Data Segmentation Analysis --

Purpose:
    - To group data into meaningful categories for targeted insights.
    - For customer segmentation, product categorization, or regional analysis.

SQL Functions Used:
    - CASE: Defines custom segmentation logic.
    - GROUP BY: Groups data into segments.
===============================================================================
*/

/* Segment products into cost ranges and count how many products fall into each segment*/
WITH product_segments AS 
(
	SELECT 
		product_key, 
		product_name, 
		cost,
		CASE
			WHEN cost > 2000 THEN 'Above 2000 '
			WHEN cost BETWEEN 1000 AND 2000 THEN '1000 - 2000'
			ELSE 'Below 1000'
		END AS cost_range
	FROM gold.dim_products
)
SELECT 
	cost_range,
	COUNT(product_key) AS total_products
FROM product_segments
GROUP BY cost_range
ORDER BY COUNT(product_key) DESC

/* 
-------------------------------------------------------------------------------------------
Group customers into three segments based on their spending behaviour:
	- VIP: Customers with atleast 12 months of history and spending more than 5,000.
	- Regular: Customers with atleast 12 months of history but spending 5,000 or less.
	- New: Customers with a lifespan less than 12 months.
And find the total numbers of customers by each group
--------------------------------------------------------------------------------------------
*/

WITH customer_spendings AS
(
	SELECT 
		c.customer_key,
		SUM(f.sales_amount) AS total_spending,
		MIN(f.order_date)  AS first_order,
		MAX(f.order_date)  AS last_order,
		DATEDIFF(month, MIN(f.order_date), MAX(f.order_date) ) AS lifespan
	FROM gold.fact_sales f
	LEFT JOIN gold.dim_customers c
		ON f.customer_key = c.customer_key
	GROUP BY c.customer_key
)
SELECT 
	customer_segments,
	COUNT(customer_key) AS total_customers
FROM (
SELECT
	customer_key,
	total_spending,
	lifespan,
	CASE 
		WHEN lifespan >= 12 AND total_spending > 5000 THEN ' VIP'
		WHEN lifespan >= 12 AND total_spending <= 5000 THEN ' Regular'
		ELSE ' New'
	END AS customer_segments
FROM customer_spendings
)t
GROUP BY customer_segments
ORDER BY total_customers DESC