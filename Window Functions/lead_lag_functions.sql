--For each statistics row with website_id = 2, show the day, the RPM and the RPM 7 days later. 
--Rename the columns to RPM and RPM_7.s:

SELECT day,
(revenue/impressions)*1000 AS RPM,
LEAD(revenue/impressions,7) OVER(ORDER BY day)*1000 AS RPM_7
FROM statistics
WHERE website_id=2

-- For each month, obtain how the store revenue changes compared to the previous month. Display:

-- the year ordered (name the column order_year)
-- the month ordered (name the column order_month)
-- the total revenue for all orders placed during that month (name the column total_sales)
-- the total revenue for all orders placed during the previous month (name the column last_month_sales)
-- the percentage change in revenue from the previous month (name the column percentage)
-- Show the most recent records first.

WITH monthly_sales AS (
  
  SELECT
    EXTRACT(YEAR FROM o.order_date) AS order_year,
    EXTRACT(MONTH FROM o.order_date) AS order_month,
    SUM(p.price * oi.quantity) AS total_sales
  FROM orders o
  JOIN order_items oi
    ON o.id = oi.order_id
  JOIN products p
    ON oi.product_id = p.id
  GROUP BY 1,2
  ORDER BY 1,2)
  
SELECT order_year, order_month, total_sales,
	LAG(total_sales) OVER(ORDER BY order_year,order_month) AS last_month_sales,
    ROUND(100*(total_sales-LAG(total_sales) OVER(ORDER BY order_year,order_month))/
    LAG(total_sales) OVER(ORDER BY order_year,order_month),2) AS percent
FROM monthly_sales
ORDER BY 1 DESC,2 DESC