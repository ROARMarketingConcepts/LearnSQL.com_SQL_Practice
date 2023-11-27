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