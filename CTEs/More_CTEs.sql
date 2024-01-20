-- A salesman performs well if his total amount earned is above average 
-- amount earned in their city. We want to show which salesmen perform well.
-- For each salesman show their first_name, last_name and the third column 
-- named label, with either 'Above average' or 'Below average', based on the total 
-- amount earned by the salesman.

WITH total_amts AS

(
  SELECT salesman_id, first_name, last_name, c.name AS city, SUM(amount_earned) AS total_amt
	FROM daily_sales ds
	LEFT JOIN salesman s
		ON ds.salesman_id=s.id
	LEFT JOIN city c
		ON s.city_id=c.id
	GROUP BY 1,2,3,4
	ORDER BY 1,2,3,4
  
 ),
 
 city_avgs AS
 
 (
  SELECT city, AVG(total_amt) AS avg_amt
 	FROM total_amts
 	GROUP BY city
 ),
 
 summary_table AS 
 
 (
  SELECT first_name, last_name, ta.city, avg_amt, total_amt
 	FROM total_amts ta
 	LEFT JOIN city_avgs ca 
 		ON ta.city=ca.city
 )
 
 SELECT first_name, last_name,
 CASE 
 	WHEN total_amt>avg_amt 
    THEN 'Above average' 
    ELSE 'Below average' END AS label
 FROM summary_table


-- Compare the average number of items sold by salesman from USA (country = 'USA') 
-- and other countries in the world. Name the group column group_name. In your query 
-- use values 'USA' and 'Other' to label the groups.


 WITH grouping AS 

(
  SELECT
    id AS city_id,
    CASE WHEN country = 'USA' THEN country ELSE 'Other' END AS group_name
  FROM city
),

total_salesman_earnings AS 

(
  SELECT
    salesman_id,
    group_name,
    SUM(items_sold) AS total_sold
  FROM daily_sales d
  JOIN salesman s
    ON d.salesman_id = s.id
  JOIN grouping g
    ON g.city_id = s.city_id
  GROUP BY salesman_id, group_name
) 

SELECT
  group_name,
  AVG(total_sold)
FROM total_salesman_earnings s
GROUP BY group_name


--------------------------------------------------------------------

-- We define 'Good' salesman as those whose total amount earned is above average amount 
-- earned in their city. We want to compare the average number of items sold between the 
-- two groups of salesmen: the 'Good' salesmen and 'Bad' salesmen.

-- 1. In the first CTE compute total amount earned by each salesman. 

-- 2. Use results of the first CTE for the second CTE to compute the city-level average.

-- 3. n the third CTE use the computes values to label salesman properly.

-- 4. In the fourth CTE, compute total number of items sold by each salesman. 

-- 5. Finally, in the outer query compute the average number of items sold per group.

WITH total_earnings AS

(	
  SELECT salesman_id, c.name AS city, 
  SUM(amount_earned) AS sum_amt_earned
	FROM daily_sales ds
	LEFT JOIN salesman s
		ON ds.salesman_id=s.id
  LEFT JOIN city c
    ON c.id=s.city_id
  GROUP BY 1,2 
),

city_avgs AS 

(
  SELECT
    city,
    AVG(sum_amt_earned) average
  FROM total_earnings
  GROUP BY 1
),

salesman_label AS 

(
  SELECT
    salesman_id,
    CASE WHEN sum_amt_earned > average THEN 'Good' ELSE 'Bad' END AS label
  FROM total_earnings te
  LEFT JOIN city_avgs ca
  	ON ca.city=te.city
),

total_items_sold AS 

(
  SELECT
    sl.salesman_id,
    label,
    SUM(items_sold) total_items
  FROM salesman_label sl 
  LEFT JOIN daily_sales ds
    ON ds.salesman_id = sl.salesman_id
  GROUP BY 1, 2
)

SELECT
  label,
  AVG(total_items) average
FROM total_items_sold
GROUP BY label
  
-------------------------------------------------------------------- 

-- A city is performing well if their total number of items sold is above 
-- average for their region. For each city show its name and its label, either 
-- 'Above average' or 'Below average', depending on how well the city performs.

WITH city_totals AS

(
  SELECT c.name AS city, c.region AS region,
  SUM(items_sold) AS total_sold
	FROM daily_sales ds
	LEFT JOIN salesman s
		ON ds.salesman_id=s.id
  LEFT JOIN city c
  	ON s.city_id=c.id
	GROUP BY 1,2
	ORDER BY 1,2
),

region_avgs AS

(
  SELECT region, AVG(total_sold) AS region_avg
	FROM city_totals
	GROUP BY 1
),

summary_table AS

(
  SELECT city,ct.region,total_sold, region_avg
	FROM city_totals ct
	LEFT JOIN region_avgs ra
		ON ct.region=ra.region
  
)

SELECT city AS name, 
CASE WHEN total_sold>region_avg 
	THEN 'Above average' 
	ELSE 'Below average' END AS label
FROM summary_table


-- For each employee from the Washington (WA) region, show the average value for all 
-- orders they placed. Show the following columns: employee_id, first_name, last_name, 
-- and avg_total_price (calculated as the average total order price, before discount).

-- In the inner query, calculate the value of each order and select it alongside the 
-- ID of the employee who processed it. In the outer query, join the CTE with the employees 
-- table to show all the required information and filter the employees by region.

WITH total_orders AS

(SELECT o.order_id,o.employee_id,
    SUM(unit_price * quantity) AS total_price
  FROM orders o
  JOIN order_items oi
    ON o.order_id = oi.order_id
  GROUP BY 1,2
  ORDER BY 2,1)
  
SELECT e.employee_id,e.first_name,e.last_name,
AVG(total_price) AS avg_total_price
FROM total_orders tot
LEFT JOIN employees e
ON tot.employee_id=e.employee_id
WHERE e.region='WA'
GROUP BY 1,2,3

-- For each employee, determine the average number of items they processed 
-- per order, for all orders placed in 2016. The number of items in an order 
-- is defined as the sum of all quantities of all items in that order. Show the 
-- following columns: first_name, last_name, and avg_item_count. In this dataset, 
-- two employees have the same first_name and last_name.

WITH items_count AS 

(SELECT o.employee_id, o.order_id, SUM(quantity) AS item_count
  FROM order_items oi
  JOIN orders o
    ON o.order_id = oi.order_id
  WHERE EXTRACT(year FROM order_date)=2016
  GROUP BY 1,2)
  
SELECT
  e.first_name,
  e.last_name,
  AVG(item_count) AS avg_item_count 
FROM items_count ic
LEFT JOIN employees e
  ON ic.employee_id = e.employee_id
GROUP BY e.employee_id,1,2     -- need to include employee_id in GROUP BY because some employees have
                               -- the same first_name and last_name.


-- For each employee, calculate the average order value (after discount) and 
-- then show the minimum average (name the column minimal_average) and the maximum 
-- average (name the column maximal_average) values.

WITH total_order_value_by_employee AS

(SELECT employee_id, oi.order_id, SUM(unit_price*quantity*(1-discount)) AS total_value
FROM order_items oi
LEFT JOIN orders o
ON o.order_id=oi.order_id
GROUP BY 1,2),

avg_order_value_by_employee AS

(SELECT employee_id, AVG(total_value) AS avg_value
FROM total_order_value_by_employee
GROUP BY 1)

SELECT MIN(avg_value) AS minimal_average, MAX(avg_value) AS maximal_average
FROM avg_order_value_by_employee

-- Among orders shipped to Italy, show all orders that had an above-average total value (before discount). 
-- Show the order_id, order_value, and avg_order_value column. The avg_order_value column should show the 
-- same average order value for all rows.

WITH order_ratings_table AS

(SELECT oi.order_id,SUM(quantity*unit_price) AS total_value,
AVG(SUM(quantity*unit_price)) OVER(ORDER BY SUM(quantity*unit_price) 
                                   ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS avg_order_value,
CASE
  WHEN SUM(quantity*unit_price)-AVG(SUM(quantity*unit_price)) OVER(ORDER BY SUM(quantity*unit_price) 
                                   ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) >= 0
  THEN 'above average' ELSE 'below average' END AS rating

FROM order_items oi
LEFT JOIN orders o
ON o.order_id=oi.order_id
WHERE ship_country='Italy'
GROUP BY 1)

SELECT order_id,total_value AS order_value,avg_order_value
FROM order_ratings_table
WHERE rating='above average'


-- For each employee, show the percentage of total revenue (before discount) generated 
-- by orders shipped to the USA and to Germany, with respect to the total revenue generated 
-- by that employee. Show the following columns:

-- employee_id.
-- first_name.
-- last_name.
-- rev_percentage_usa.
-- rev_percentage_germany.
-- Round the percentages to two decimal places.

WITH total_revenue_by_employee AS

(SELECT employee_id, SUM(quantity*unit_price) AS total_revenue
FROM order_items oi
LEFT JOIN orders o
  ON oi.order_id=o.order_id
GROUP BY 1
ORDER BY 1),

usa_revenue AS

(SELECT employee_id, SUM(quantity*unit_price) AS USA_revenue
FROM order_items oi
LEFT JOIN orders o
  ON oi.order_id=o.order_id
WHERE ship_country ='USA'
GROUP BY 1
ORDER BY 1),

germany_revenue AS

(SELECT employee_id, SUM(quantity*unit_price) AS germany_revenue
FROM order_items oi
LEFT JOIN orders o
  ON oi.order_id=o.order_id
WHERE ship_country ='Germany'
GROUP BY 1
ORDER BY 1),

revenue_breakout AS 

(SELECT tre.employee_id,COALESCE(usa_revenue,0) AS usa_revenue,
  COALESCE(germany_revenue,0) AS germany_revenue,total_revenue
FROM total_revenue_by_employee tre
LEFT JOIN usa_revenue u
  ON u.employee_id=tre.employee_id
LEFT JOIN germany_revenue g
  ON tre.employee_id=g.employee_id)

SELECT e.employee_id, first_name,last_name,
ROUND(usa_revenue/total_revenue*100,2) AS rev_percentage_usa,
ROUND(germany_revenue/total_revenue*100,2) AS rev_percentage_germany
FROM revenue_breakout rb
LEFT JOIN employees e
  ON rb.employee_id=e.employee_id


-- For each person who made donations in the 'music' or 'traveling' categories, show three columns:

-- supporter_id
-- min_music – That person's minimum donation amount in the music category.
-- max_traveling – That person's maximum donation amount in the traveling category.

-- First, use a CTE to find all users that donated to either music or traveling projects. 
-- Then, use two CTEs – one for finding the minimum for music category, and one for finding 
-- the maximum in traveling category. In each CTE, select the supporter_id. In the outer 
-- query, join all your CTEs' results on supporter_id.

-- Use LEFT JOIN to show all the results.


WITH all_supporters AS 

(SELECT supporter_id
FROM project p
LEFT JOIN donation d
ON d.project_id = p.id
WHERE category IN ('music','traveling')
GROUP BY 1),

music_supporters AS

(SELECT supporter_id, MIN(amount) AS min_music
FROM project p
LEFT JOIN donation d
ON d.project_id = p.id
WHERE category IN ('music')
GROUP BY 1),

traveling_supporters AS 

(SELECT supporter_id, MAX(amount) AS max_traveling
FROM project p
LEFT JOIN donation d
ON d.project_id = p.id
WHERE category IN ('traveling')
GROUP BY 1)

SELECT alls.supporter_id, min_music,max_traveling
FROM all_supporters alls
LEFT JOIN traveling_supporters ts
ON ts.supporter_id=alls.supporter_id
LEFT JOIN music_supporters ms
ON ms.supporter_id=alls.supporter_id



