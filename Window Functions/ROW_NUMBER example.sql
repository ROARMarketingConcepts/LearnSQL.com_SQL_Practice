-- For patients who visited the clinic during February 2024, find the test performed the most for each age group. Display:

-- age_group (see below).
-- The test name.
-- The number of times the test was performed (name this column performed).
-- The age_group is assigned as follows:

-- 'Young Adults': ages 18 to 24
-- 'Adults': ages 25 to 65
-- 'Seniors': ages above 65
-- Order the results by the number of times performed in descending order and then alphabetically by age_group.



WITH tests_age_group AS 

(SELECT t.id,
  		t.name,
		CASE WHEN age BETWEEN 18 AND 24 THEN 'Young_Adults'
    	 	WHEN age BETWEEN 25 AND 65 THEN 'Adults'
         	ELSE 'Seniors' END AS age_group
FROM visit v
LEFT JOIN visit_test vt
ON vt.visit_id=v.id
LEFT JOIN patient p
ON v.patient_id = p.id
LEFT JOIN test t
ON vt.test_id=t.id
WHERE date BETWEEN '2024-02-01' AND '2024-02-29'),

tests_performed AS 

(
  SELECT 
	age_group,
  	name,
 	COUNT(id) AS performed
FROM tests_age_group
GROUP BY 1,2
ORDER BY 3 DESC, 1
),

test_rankings AS 

(SELECT 
	age_group,
   	name,
	performed,
    ROW_NUMBER() OVER(PARTITION BY age_group ORDER BY performed DESC) AS row_number
FROM tests_performed)

SELECT 
	age_group,
   	name,
	performed
FROM test_rankings
WHERE row_number=1
ORDER BY 3 DESC, 1
