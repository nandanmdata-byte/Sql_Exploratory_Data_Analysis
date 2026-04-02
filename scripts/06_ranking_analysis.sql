/*
==========================================================================================

-- | Ranking Analysis | --

Purpose:
    - To rank each category of items (e.g., products, customers) based on performance or other metrics.
    - To explore and identify top performers or laggards.

SQL Functions Used:
    - Window Ranking Functions: RANK(), ROW_NUMBER(), TOP
    - Clauses: GROUP BY, ORDER BY
==========================================================================================
*/

-- Find 5 best-performing products that generate the highest revenue 
-- Simple ranking query:
SELECT TOP 5
	p.product_key,
	p.product_name,
	SUM(f.sales_amount) AS total_revenue
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p 
	ON f.product_key = p.product_key
GROUP BY p.product_key, p.product_name
ORDER BY total_revenue DESC;

-- Using Window Function --
SELECT *
FROM (
	SELECT 
		p.product_key,
		p.product_name,
		SUM(f.sales_amount) AS total_revenue,
		ROW_NUMBER() OVER(ORDER BY SUM(f.sales_amount) DESC) rank_products
	FROM gold.fact_sales f
	LEFT JOIN gold.dim_products p 
		ON f.product_key = p.product_key
	GROUP BY p.product_key, p.product_name
) AS ranked_products
WHERE rank_products <= 5;

-- Find 5 worst - performing products that generate the lowest revenue

SELECT *
FROM (
	SELECT 
		p.product_key,
		p.product_name,
		SUM(f.sales_amount) AS total_revenue,
		ROW_NUMBER() OVER(ORDER BY SUM(f.sales_amount) ASC) rank_products
	FROM gold.fact_sales f
	LEFT JOIN gold.dim_products p 
		ON f.product_key = p.product_key
	GROUP BY p.product_key, p.product_name
) AS ranked_products
WHERE rank_products <= 5;

-- Find the Top 10 customers who generated the highest revenue 

SELECT TOP 10
	c.customer_key,
	c.first_name,
	c.last_name,
	SUM(f.sales_amount) AS total_revenue
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c 
	ON f.customer_key = c.customer_key
GROUP BY c.customer_key,
		 c.first_name,
		 c.last_name
ORDER BY total_revenue DESC;

-- 3 customers with the fewest orders placed

SELECT TOP 3
	c.customer_key,
	c.first_name,
	c.last_name,
	COUNT(DISTINCT f.order_number) AS total_orders
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c 
	ON f.customer_key = c.customer_key
GROUP BY c.customer_key,
		 c.first_name,
		 c.last_name
ORDER BY total_orders ASC;


