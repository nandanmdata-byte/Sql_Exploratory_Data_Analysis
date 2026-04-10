/*
========================================================================================

PRODUCT REPORT

========================================================================================

Purpose:
	- Provides a unified view of product metrics and sales patterns.

Key Features:
	1. Captures core profile data fields such as name, category, subcategory and cost.
	2. Tiered Classification: Segment products into categories ( High-Performers, Mid-Range, Low-Performers)
	based on revenue.
	3. Aggregates product - level performance metrics:
		Computes high - level total measures such as
		- total sales
		- total orders
		- total quantity sold
		- total customers ( Unique )
		- lifespan ( in months )
	4. Calculates the valuable business KPIs:
		- recency ( months since last sale )
		- average order revenue ( AOR )
		- average monthly revenue

========================================================================================
*/

IF OBJECT_ID('gold.report_products', 'V') IS NOT NULL
	DROP VIEW gold.report_products;

GO

CREATE VIEW gold.report_products AS
WITH product_base_query AS
(
/*
------------------------------------------------------------------------------------------------------
1) Base Query: Retrieves core columns from tables
------------------------------------------------------------------------------------------------------
*/
SELECT
	f.order_number,
	f.order_date,
	f.customer_key,
	f.sales_amount,
	f.quantity,
	p.product_key,
	p.product_name,
	p.category,
	p.subcategory,
	p.cost
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
	ON f.product_key = p.product_key
WHERE f.order_date IS NOT NULL -- valid dates only
)
,product_aggregations AS (
/*
------------------------------------------------------------------------------------------------------
2) Product Aggregations Query: Aggregates key metrics at product level for a comprehensive view
------------------------------------------------------------------------------------------------------
*/
SELECT
	product_key,
	product_name,
	category,
	subcategory,
	cost,
	COUNT(DISTINCT order_number) AS total_orders,
	COUNT( DISTINCT customer_key) AS total_customers,
	SUM(sales_amount) AS total_sales,
	SUM(quantity) AS total_qty_sold,
	MAX(order_date) AS last_order_date,
	DATEDIFF( month, MIN(order_date), MAX(order_date)) AS lifespan,
	ROUND(AVG(CAST(sales_amount AS FLOAT)/NULLIF(quantity,0)),1) AS avg_selling_price
FROM product_base_query
GROUP BY 
	product_key,
	product_name,
	category,
	subcategory,
	cost
)
/*
------------------------------------------------------------------------------------------------------
3) Final Query: Combine all the product results into one final output
------------------------------------------------------------------------------------------------------
*/

SELECT
	product_key,
	product_name,
	category,
	subcategory,
	cost,
	last_order_date,
	DATEDIFF(month, last_order_date, GETDATE()) AS recency_in_months,
	-- Product segmentation based on total revenue 
	CASE
		WHEN  total_sales > 50000 THEN 'High-Performers'
		WHEN  total_sales >= 10000 THEN 'Mid-Range'
		ELSE 'Low-Performers'
	END AS product_segments,
	lifespan,
	total_sales,
	total_orders,
	total_qty_sold,
	total_customers,
	avg_selling_price,

	-- Compute the average order revenue ( AOR )
	CASE
		WHEN total_orders = 0 THEN 0
		ELSE total_sales/total_orders 
	END AS avg_order_revenue,

	-- Compute the average monthly revenue 
	CASE 
		WHEN lifespan = 0 THEN total_sales
		ELSE total_sales/ lifespan 
	END AS avg_monthly_revenue
FROM product_aggregations;