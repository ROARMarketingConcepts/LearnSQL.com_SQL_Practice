-- We want to find the ratio of the revenue from all discounted items to the total revenue 
-- from all items. We'll do this in steps too.

-- First, show two columns:

-- discounted_revenue – the revenue (after discount) from all discounted line items in all orders.
-- total_revenue – the total revenue (after discount) from line items in all orders.

SELECT 
	SUM(CASE WHEN discount <> 0.00 
        THEN quantity*unit_price*(1-discount) END) AS discounted_revenue,
	SUM(quantity*unit_price*(1-discount)) AS total_revenue
FROM order_items 

-- What is the percentage of discontinued items at Northwind? 
-- Show three columns: count_discontinued, count_all, and percentage_discontinued. 
-- Round the last column to two decimal places.

SELECT 
	COUNT(CASE WHEN discontinued='t' THEN discontinued ELSE NULL END) AS count_discontinued,
    COUNT(discontinued) AS count_all,
    ROUND(CAST(COUNT(CASE WHEN discontinued='t' THEN discontinued ELSE NULL END) AS decimal)/
    	COUNT(discontinued)*100,2) AS percentage_discontinued
FROM products



-- Create a report to show the percentage of total revenue after discount generated 
-- by orders with low (less than or equal to 90.0) and high (greater than 90.0) freight 
-- values in each country we ship to.

-- Show the following columns: ship_country, percentage_low_freight, and percentage_high_freight.
-- Round the percentages to two decimal places.

WITH freight_revenue_by_country AS

(SELECT ship_country,
	CASE WHEN freight<=90 THEN SUM(quantity*unit_price*(1-discount)) ELSE 0 END AS low_freight_revenue,
    CASE WHEN freight>90 THEN SUM(quantity*unit_price*(1-discount)) ELSE 0 END AS high_freight_revenue,
    (CASE WHEN freight<=90 THEN SUM(quantity*unit_price*(1-discount)) ELSE 0 END) + 
    (CASE WHEN freight>90 THEN SUM(quantity*unit_price*(1-discount)) ELSE 0 END) AS total_revenue
FROM order_items oi
LEFT JOIN orders o
ON oi.order_id=o.order_id
GROUP BY 1, o.freight)

SELECT 
	ship_country, 
    ROUND(SUM(low_freight_revenue)/SUM(total_revenue)*100,2) AS percentage_low_freight,
    ROUND(SUM(high_freight_revenue)/SUM(total_revenue)*100,2) AS percentage_high_freight
FROM freight_revenue_by_country
GROUP BY 1