-- For each category and material, display the total price of products that belong to this category 
-- or are made of this material. (Call this column total_price.)

-- Note: We do not want to combine categories and materials. Calculate the total_price 
-- for each category (regardless of the material) and for each material (regardless of the category). 
-- Display the result in one table.

SELECT product_category,material, SUM(price) AS total_price
FROM product
GROUP BY GROUPING SETS(product_category, material);

-- Output below:

-- product_category		material	total_price
--------------------------------------------
-- Earrings				      null			375
-- Bracelet				      null			350
-- Ring					        null			535
-- Set					        null			850
-- null					        Clay			250
-- null					        Gold			725
-- null					      Silver			1135

-------------------------------------------------------------------

-- GROUP BY ROLLUP

-- Apart from averages by contestant and category, we can also see averages by contestant and 
-- an overall average across all contestants and categories.

SELECT
  full_name,
  category, 
  AVG(score) AS avg_score
FROM contest_score
GROUP BY ROLLUP (full_name, category);

-- The column order matters in the GROUP BY ROLLUP statement.

-- GROUP BY CUBE 

-- another GROUP BY extension that is mainly used in ETL processes (i.e., 
-- when working with data warehouses and creating advanced reports).
-- In principle, ROLLUP and CUBE are similar. The difference is that CUBE 
-- does not remove columns from the right to create grouping levels. Instead, 
-- it creates every possible grouping combination based on the columns inside 
-- its parentheses.

-- We need to be aware that CUBE can significantly lower the performance of our queries. 
-- As few as three columns in CUBE create eight different types of groupings. Even though 
-- a query with CUBE is faster than separate grouping queries merged with UNION, performance 
-- can still be an issue for large tables.


WITH totals_by_customer_purchase_id AS
(SELECT name, purchase_id, COALESCE(SUM(price),0) AS total_price
FROM customer c
LEFT JOIN purchase pu
ON pu.customer_id=c.id
LEFT JOIN product pr
ON pu.id=pr.purchase_id
GROUP BY 1,2
ORDER BY 1,2)

SELECT name,ROUND(AVG(total_price),2) AS avg_purchase_price
FROM totals_by_customer_purchase_id
GROUP BY 1
ORDER BY 2 DESC
