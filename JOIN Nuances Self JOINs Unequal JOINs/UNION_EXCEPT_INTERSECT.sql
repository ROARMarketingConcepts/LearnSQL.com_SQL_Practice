-- Find all the countries which have a medal in cycling but not in skating.

SELECT country
FROM cycling
EXCEPT
SELECT country
FROM skating


-- Find all the years when there was at least one medal in skating but no medals 
-- in cycling. Use the keyword MINUS.

SELECT year FROM skating 
MINUS
SELECT year FROM cycling

-- Display students' first and last names. Select only those students who meet BOTH of the following criteria:

-- At least 3 of their final grades are higher than their midterm grades, and
-- Their average final grade in the Mathematics learning path was at least 50.

SELECT 
	first_name,
    last_name
FROM course_enrollment cen
JOIN student s
ON cen.student_id = s.id
GROUP BY 1,2
HAVING SUM(CASE WHEN final_grade-midterm_grade > 0 THEN 1 ELSE 0 END) >= 3

INTERSECT

SELECT 
	first_name,
    last_name
FROM course_enrollment cen
JOIN student s
ON cen.student_id = s.id
JOIN course_edition ce
ON cen.course_edition_id = ce.id
JOIN course c
ON ce.course_id = c.id
WHERE learning_path = 'Mathematics'
GROUP BY 1,2
HAVING AVG(final_grade) >= 50


