-- Create a report of the category revenue for orders shipped to Germany. 
-- Show three columns: category_name, category_revenue, and total_revenue_ratio. 
-- The last column should show the ratio of category revenue to total revenue generated 
-- by orders shipped to Germany.

WITH all_categories AS (
  SELECT SUM(amount) AS total_sum
  FROM orders
  WHERE ship_country='Germany'
)
SELECT 
  category_name,
  SUM(oi.amount) AS category_revenue,
  SUM(oi.amount) / CAST(ac.total_sum AS DECIMAL(10,2)) AS total_revenue_ratio
FROM all_categories ac, order_items oi
JOIN orders o
  ON o.order_id = oi.order_id
JOIN products p
  ON oi.product_id = p.product_id
JOIN categories c
  ON p.category_id = c.category_id
WHERE ship_country='Germany'
GROUP BY 
  category_name,
  ac.total_sum;

-- For each category, find the December 2016 revenue and show it alongside the ratio of that 
-- category's revenue to the total revenue for December 2016. 
-- Show the following columns: category_name, category_revenue, and total_revenue_ratio. 
-- Round the total_revenue_ratio to 2 decimal places.

WITH total_revenue_december_2016 AS 

(SELECT SUM(amount) AS total_sum
FROM orders
WHERE order_date BETWEEN '2016-12-01' AND '2016-12-31')

SELECT 
  category_name,
    SUM(oi.amount) AS category_revenue,
    ROUND(SUM(oi.amount) / CAST(trd.total_sum AS DECIMAL(10,2)),2) AS total_revenue_ratio
FROM total_revenue_december_2016 trd, orders o
LEFT JOIN order_items oi
ON o.order_id=oi.order_id
LEFT JOIN products p
ON oi.product_id=p.product_id
LEFT JOIN categories c
ON p.category_id=c.category_id
WHERE order_date BETWEEN '2016-12-01' AND '2016-12-31'
GROUP BY 1,trd.total_sum