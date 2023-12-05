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




