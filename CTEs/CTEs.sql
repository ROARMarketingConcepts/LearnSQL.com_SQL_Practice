-- Show the first and last name of authors with the number of 
-- not yet founded projects they created. Show projects_count as 
-- the third column. Show the authors in descending order of projects_count. 
-- Remember, the author must be a supporter.

-- In the CTE, join project with donation tables and group by the author's ID, 
-- the project's ID and the minimal_amount to be able to calculate the sum of donations.
-- Recall that "not yet founded projects" are projects with the sum of donations smaller
-- than minimal_amount.


WITH project_revenue AS (
  SELECT
    project.id, 
    SUM(amount) AS sum_amount
  FROM project
  JOIN donation
    ON donation.project_id = project.id
  GROUP BY project.id
)

SELECT first_name,last_name, COUNT(*) AS projects_count
FROM project_revenue pr
LEFT JOIN project p
ON p.id=pr.id
LEFT JOIN supporter s
ON s.id=p.author_id
WHERE pr.sum_amount<=p.minimal_amount
GROUP BY 1,2
ORDER BY 3 DESC


--For each person who made donations in 'music' or 'traveling' categories, show three columns:

-- supporter_id,
-- min_music – that person's minimum donation amount in the 'music' category,
-- max_traveling – that person's maximum donation amount in the 'traveling' category.

-- First, you should use CTE to find all users that donated to either 'music' or 'traveling' 
-- projects. Then, use two CTEs, one for finding the minimum for 'music' category, the other 
-- one for finding the maximum in 'traveling' category. In each CTE, select the supporter_id 
-- as well. In the outer query, join all your CTEs results on the supporter_id.

-- In order to show all the results use LEFT JOIN.

WITH supporters AS 

(
  SELECT DISTINCT
    supporter_id
  FROM donation d 
  JOIN project p
    ON d.project_id = p.id 
  WHERE category IN ('music', 'traveling')
),

music AS (
  SELECT
    supporter_id,
    MIN(amount)
  FROM donation d 
  JOIN project p
    ON d.project_id = p.id 
  WHERE category IN ('music')
  GROUP BY 1
),

traveling AS (
  SELECT
    supporter_id,
    MAX(amount)
  FROM donation d 
  JOIN project p
    ON d.project_id = p.id 
  WHERE category IN ('traveling')
  GROUP BY 1
)

SELECT
  s.supporter_id,
  m.min AS min_music,
  tr.max AS max_traveling
FROM supporters s
LEFT JOIN music m
  ON m.supporter_id = s.supporter_id
LEFT JOIN traveling tr
  ON tr.supporter_id = s.supporter_id

--Note: it is not possible to create correlated subqueries with CTEs.

-- Show the average total amount raised in successful projects that had 
-- more than 10 donations.

WITH ten_or_more AS

(
  SELECT project_id, 
    p.minimal_amount, 
    COUNT(d.id) AS count_donations, 
    SUM(amount) AS sum_amount
  FROM project p
  LEFT JOIN donation d
  ON d.project_id=p.id
  GROUP BY 1,2
  HAVING SUM(amount) > minimal_amount
  
)

SELECT AVG(sum_amount)
FROM ten_or_more t
WHERE count_donations>10

-- Among successful projects, those that raised 100% to 150% of the minimum amount 
-- are good projects, whereas those that raised more than 150% are great projects. 
-- Show the number of projects along with a string representing how good the project 
-- is (good projects or great projects) name the column tag.


WITH good_projects AS

(
  SELECT project_id,minimal_amount,SUM(amount)
  FROM donation d
  LEFT JOIN project p
  ON d.project_id=p.id
  GROUP BY 1,2
  HAVING SUM(amount) BETWEEN minimal_amount AND 1.5*minimal_amount
),

great_projects AS 

(
  SELECT project_id,minimal_amount,SUM(amount)
  FROM donation d
  LEFT JOIN project p
  ON d.project_id=p.id
  GROUP BY 1,2
  HAVING SUM(amount) > 1.5*minimal_amount
)

SELECT COUNT(project_id) AS count, 'good projects' AS tag
FROM good_projects
UNION
SELECT COUNT(project_id) AS count, 'great projects' AS tag
FROM great_projects


-- Nested CTEs: Once we define a CTE, we can freely use it in subsequent CTEs.


-- First, find daily sums of amount_earned in each city. 

WITH sums AS

(
  SELECT c.id, c.name AS city, ds.day, SUM(amount_earned) AS total_amt
  FROM daily_sales ds
  LEFT JOIN salesman s
    ON ds.salesman_id=s.id
  LEFT JOIN city c
    ON s.city_id=c.id
  GROUP BY c.id,c.name,ds.day
 ),
  

--Find the average daily amount for all cities for all days. 

average AS

(
  SELECT AVG(total_amt) AS avg_amt
  FROM sums 
)  -- Answer = 2543.483


-- Finally, show the id and name of each city plus the number of daily sums 
-- that exceeded the average daily amount for each given city.

SELECT id,city AS name,COUNT(*)
FROM sums
WHERE total_amt>
(SELECT avg_amt FROM average)
GROUP BY 1,2


-- First, find the total number of customers in each region on each day. 
-- Then, calculate the average number of customers across all regions on each day.

-- Finally, show the day with the lowest average across all regions (that means, 
-- show the day and the avg_region_customers).

WITH total_customers_region_day AS

(
  SELECT region,day,SUM(customers) AS total_customers
  FROM daily_sales ds
  LEFT JOIN salesman s
  ON s.id=ds.salesman_id
  LEFT JOIN city c
  ON s.city_id=c.id
  GROUP BY 1,2
  ORDER BY 1,2
),

--Then, calculate the average number of customers across all regions on each day.

avg_cust_cnt_day_all_regions AS 

(
  SELECT day, AVG(total_customers) AS avg_region_customers
  FROM total_customers_region_day
  GROUP BY day
) 

SELECT day,avg_region_customers
FROM avg_cust_cnt_day_all_regions
WHERE avg_region_customers=
  (
    SELECT MIN(avg_region_customers)
  FROM avg_cust_cnt_day_all_regions
  )

