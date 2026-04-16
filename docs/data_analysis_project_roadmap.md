

# Data Analysis Project Roadmap

The purpose of this documentation is to give a clear overview on the different kind of analytics techniques, both basic and advanced as well as the different command keywords used in this project. 

<br>

## Table of contents

1. [Dimensions and Measures](#1-dimensions-and-measures)
2. [Database Exploration](#2-database-exploration)
3. [Dimensions Exploration](#3-dimensions-exploration)
4. [Date Exploration](#4-date-exploration)
5. [Measures Exploration](#5-measures-exploration)
6. [Magnitude Analysis](#6-magnitude-analysis)
7. [Ranking](#7-ranking)
8. [Change-Over-Time](#8-change-over-time-analysis)
9. [Cumulative Analysis](#9-cumulative-analysis)
10. [Performative Analysis](#10-performance-analysis)
11. [Part-to-Whole](#11part-to-whole-analysis)
12. [Data Segmentation](#12data-segmentation)
13. [Reporting](#13-reporting)

<br>

---

### 1. Dimensions and Measures

To analyze data effectively, we categorize the columns in our database into two types: **Dimensions** and **Measures**. This distinction helps us think logically about how to slice and dice our datasets.

*   **Dimensions**: Descriptive attributes used to group or filter data. 
    - *Non-numeric data*: `country`, `first_name`, `product_category`.
    - *Numeric data (non-aggregatable)*: `customer_id`, `order_year`, `birthdate`.
*   **Measures**: Quantitative or Numeric values that we can perform math on.
    - *Numeric data (aggregatable)*: `sales_amount`, `quantity`, `tax_paid`.

**Quick rule:** Whenever we are presented with a numeric value ask the question, *"Does it make sense to SUM this?"* If yes, it's a **Measure**. If no (like it's a phone number or ID), it's a **Dimension**.

<br>

---

### 2. Database Exploration

Database exploration is a critical preliminary phase taken in any *Exploratory Data Analysis ( EDA )* project. Before jumping straight into the newly introduced data sets to draw conclusions, we take this "pre step" in order to understand our data thoroughly like:

- Deriving a comprehensive inventory about all the objects in database ( table, view etc.) 
- An overview on important details about the database columns (column_name, data_type etc. )

---

### 3. Dimensions Exploration

Identifying the unique values (or categories) in each dimension.
Recognizing how data might be grouped or segmented, which is useful for later analysis.

**Logic :** 

- **DISTINCT`[Dimension]`**

**E.g.:**
<details>
<summary>click here to view the sql example</summary>

```sql
SELECT DISTINCT 
  country 
FROM gold.dim_customers;
```
</details>

---

### 4. Date Exploration

Identifying the earliest and latest dates ( Boundaries).<br>
Understand the scope of data and the lifespan. This is important to understand in order to make different types of time analysis later.

**Logic:**  

- **MIN/MAX** `[Date Dimension]`

**E.g.:**
<details>
<summary>click here to view the sql example</summary>

```sql
SELECT 
  MIN(order_date) AS first_order_date,
  MAX(order_date) AS last_order_date
FROM gold.dim_customers;
```
</details>

---

### 5. Measures Exploration

In order to calculate the key metrics of the business (Big Numbers).

Highest Level of Aggregation | Lower Level of Details 

**Logic :**

- $\sum$`[Measure]`

where $\sum$ is the aggregate function like SUM, AVG etc.

**E.g.:** 
<details>
<summary>click here to view the sql example</summary>

```sql
SELECT 
  SUM(sales_amount) AS total_sales
FROM gold.fact_sales;
```
</details>

---

### 6. Magnitude Analysis

In order to compare the measure values by categories (Dimensions). It helps us to understand the importance of different categories.

**Logic:**

  -  $\sum$`[Measure]` BY `[Dimension]`

<br>

First aggregate a measure and then split it by a dimension.

**E.g.:** 
<details>
<summary>click here to view the sql example</summary>

```sql
SELECT  
  country,
  COUNT( customer_key) AS total_customers
FROM gold.dim_customers 
GROUP BY country;
```
</details>
<br>
So, we can understand which dimension category is best and which is worst.

---

### 7. Ranking

Using ranking functions to 'order' the values of dimensions based on measure, in order to identify the ***Top N*** performers or the ***Bottom N*** performers.

**Logic :**
- RANK`[Dimension]` BY $\sum$ `[Measure]`

**E.g.:** 
<details>
<summary>click here to view the sql example</summary>

```sql
SELECT 
 product_key,
 COUNT(product_key) AS total_products_sales,
 ROW_NUMBER() OVER(ORDER BY COUNT(product_key) DESC) AS product_ranking
FROM gold.fact_sales
GROUP BY product_key;
```
</details>

---

### 8. Change Over Time Analysis

Analysis of how a measure evolves over time. Helps in order to track the trends and identify seasonality in our data.

Formula is that we aggregate a Measure based on a Date Dimension.

**Logic:**

-  $\sum$`[Measure]` BY `[Date Dimension]`

**E.g.:** 
<details>
<summary>click here to view the sql example</summary>

```sql
SELECT
  YEAR(order_date) AS order_year,
  SUM(sales_amount) AS total_sales
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date)
ORDER BY YEAR(order_date) DESC;
```
</details>

<br>

---

### 9. Cumulative Analysis


Cumulative analysis is *aggregating the data progressively over the time*. This is an important technique in order to understand how our business is growing over the time. Whether it is growing or declining.

**Logic**:

-  $\sum$`[Cumulative Measure]` BY `[Date Dimension]`

**E.g.:** 

<details>
<summary>click here to view the sql example</summary>

```sql
SELECT
  order_year,
  -- calculating running total based on aggregated yearly sales
  SUM(yearly_sales) OVER ( ORDER BY order_year) AS running_total_sales
FROM
(
SELECT
  YEAR(order_date) AS order_year,
  SUM(sales_amount) AS yearly_sales
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date)
)t;
```
</details>

<br>

----

### 10. Performance Analysis

Comparing the current value to the target value.
<br>
**Performance Analysis** is done in order to compare the performance of specific category.
This helps us in order to measure success and compare performance.

**Logic:**

- Current`[Measure]` - Target`[Measure]`

**E.g.:** 

Current Sales - Average Sales, Current Year Sales - Previous Year Sales (YoY Analysis) etc

<details>
<summary>click here to view sql example</summary>

```sql
WITH yearly_sales AS (
SELECT
	YEAR(order_date) AS order_year,
	SUM(sales_amount) AS total_sales
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date)
)
SELECT
	order_year AS current_year,
	total_sales AS current_year_sales,
	LAG(order_year,1) OVER( ORDER BY order_year) AS previous_year,
	LAG(total_sales,1) OVER( ORDER BY order_year) AS previous_year_sales,
	total_sales - (LAG(total_sales,1) OVER( ORDER BY order_year)) AS sales_difference
FROM yearly_sales;

```

</details>

<br>

---

### 11.	Part-to-Whole Analysis

Part - to - Whole Analysis or Proportional Analysis is the analysis of how an individual part is performing compared to the overall. <br> This is done in order to understand which category has the greatest impact on the business.

**Logic:** 

- (`[Measure]`  / Total `[Measure]`)*100 BY `[Dimension]`

**E.g.:** 

(Sales/Total Sales) * 100 BY Category,  (Quantity/Total Quantity) * 100 BY Country etc.

<details>
<summary>click here to view sql example</summary>

```sql

WITH country_sales AS (
SELECT
	SUM(fs.sales_amount) AS total_sales,
	country
FROM gold.fact_sales AS fs
LEFT JOIN gold.dim_customers AS dc
ON fs.customer_key = dc.customer_key
GROUP BY country
) 
SELECT
	total_sales,
	country,
	SUM(total_Sales) OVER() overall_sales,
	round(total_sales * 100.0 / SUM(total_sales) OVER(), 2) AS sales_percent_by_country
FROM country_sales
ORDER BY total_sales DESC;

```

</details>

<br>

---

### 12.	Data Segmentation

Grouping up the data based on a specific range. Meaning, we create new categories and then go aggregate the data based on the new category.
Helps us to understand the correlation between two measures.

**Logic:** 

- `[Measure]` BY `[Measure]`

*Note: In order to create new categories and segments in SQL, we use CASE WHEN Statement.*

**E.g.:** 

Total Products BY Sales Range, Total Customers BY Age etc.

<details>
<summary>click to view sql example</summary>

```sql
SELECT 
    product_key,
    product_name,
    cost,
    CASE
        WHEN cost < 100  THEN 'Low Cost'
        WHEN cost < 500  THEN 'Medium Cost'
        WHEN cost < 1000 THEN 'High Cost'
        ELSE 'Premium'
    END AS cost_category
FROM gold.dim_products;
```
</details>

<br>

---

### 13. Reporting

The final stage of this project integrates and organises these techniques into curated SQL VIEWS. This ensures data security by abstracting complex logic and providing a clean interface for stakeholders and BI tools.

- gold.report_customers: Comprehensive customer behavior and segmentation.
- gold.report_products: Detailed product performance and magnitude analysis.