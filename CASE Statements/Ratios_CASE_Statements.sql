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
