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