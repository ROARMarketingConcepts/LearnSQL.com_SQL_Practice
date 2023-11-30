-- For each project, show project_id and an average number of 
-- hours an employee spent on a project.

WITH total_hours AS 

	(SELECT project_id, employee_id, SUM(hours_spent) AS total_hours
	FROM allocation
	GROUP BY 1,2
	ORDER BY 1,2)

SELECT project_id, AVG(total_hours)
FROM total_hours
GROUP BY project_id


-- Find the maximum number of hours an employee spent in 
-- total on the project with ID 1 (first column named first_max) 
-- and on the project with ID 2 (second column named second_max).

WITH total_hours_project_id_1 AS

	(SELECT project_id, employee_id, SUM(hours_spent) AS total_hours
	FROM allocation
	WHERE project_id=1
	GROUP BY 1,2),
    
total_hours_project_id_2 AS

	(SELECT project_id, employee_id, SUM(hours_spent) AS total_hours
	FROM allocation
	WHERE project_id=2
	GROUP BY 1,2)
    
SELECT
	MAX(A.total_hours) AS first_max,
    MAX(B.total_hours) AS second_max
FROM total_hours_project_id_1 A, total_hours_project_id_2 B


-- First, find the sum of hours spent by each employee on each project. 
-- Then, find the maximum number of hours spent by a single employee on each project. 
-- Finally, find the average maximum of hours among all these projects.

WITH sum_by_employee AS

	(SELECT employee_id,project_id, SUM(hours_spent) AS sum_single_employee
	FROM allocation
	GROUP BY 1,2
	ORDER BY 1,2),
    
max_by_project AS

(SELECT project_id, MAX(sum_single_employee) AS max_single_employee
FROM sum_by_employee
GROUP BY 1
ORDER BY 1)

SELECT AVG(max_single_employee)
FROM max_by_project

-- First, count the number of employees for each project with total number of 
-- hours_spent higher than 20. Then, find the average number of such employees 
-- for a given client. Finally, show the maximal_average alongside the client_id 
-- whom the maximal average concerns.

WITH projects_gt_20_hours AS

	(SELECT project_id,  SUM(hours_spent) AS total_project_hours
	FROM allocation
	GROUP BY 1
	HAVING SUM(hours_spent) > 20
	ORDER BY 1),
    
num_employees_per_project AS

	(SELECT project_id, COUNT(DISTINCT employee_id) AS num_employees
	FROM allocation
	WHERE project_id IN 
	(SELECT project_id FROM projects_gt_20_hours)
	GROUP BY 1
	ORDER BY 1),
    

avg_employees_per_client AS

	(SELECT client_id, AVG(num_employees)
	FROM project p
	LEFT JOIN num_employees_per_project ne
	ON p.id=ne.project_id
	WHERE p.id IN (SELECT project_id FROM projects_gt_20_hours)
	GROUP BY 1)
    
SELECT avg AS maximal_average, client_id
FROM avg_employees_per_client
WHERE avg = 
(SELECT MAX(avg) from avg_employees_per_client)

---------  OR  --------------------------------------------

WITH employee_20h AS (
  SELECT
    project_id,
    COUNT(distinct employee_id) AS count_employees_project
  FROM allocation
  GROUP BY project_id
  HAVING SUM(hours_spent) >= 20
),
average_client AS
(
  SELECT
    client_id,
    AVG(count_employees_project) AS maximal_average
  FROM employee_20h e20
  JOIN project pr
    ON e20.project_id = pr.id
  GROUP BY client_id
)
SELECT maximal_average, client_id
FROM average_client
WHERE maximal_average = (SELECT MAX(maximal_average) FROM average_client);


















