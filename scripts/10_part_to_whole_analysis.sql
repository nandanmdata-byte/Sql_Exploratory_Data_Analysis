/*
===============================================================================

-- Part-to-Whole Analysis --

Purpose:
    - To compare performance or metrics across dimensions or time periods.
    - To evaluate differences between categories.
    - Useful for A/B testing or regional comparisons.

SQL Functions Used:
    - SUM(), AVG(): Aggregates values for comparison.
    - Window Functions: SUM() OVER() for total calculations.
===============================================================================
*/
-- Which categories contribute the most to overall sales?
WITH category_sales AS
(
	SELECT 
		p.category, 
		SUM(f.sales_amount) AS total_sales,
		SUM(SUM(f.sales_amount)) OVER() AS overall_Sales
	FROM gold.fact_sales f
	LEFT JOIN gold.dim_products p
		ON f.product_key = p.product_key
	GROUP BY p.category
)
SELECT 
	category, 
	total_sales,
	overall_Sales,
	CONCAT(CAST((total_sales*100.0/NULLIF(overall_Sales,0)) AS DECIMAL(12,2)) ,'%') AS contribution
FROM category_sales
ORDER BY (total_sales*100.0/NULLIF(overall_Sales,0)) DESC;
