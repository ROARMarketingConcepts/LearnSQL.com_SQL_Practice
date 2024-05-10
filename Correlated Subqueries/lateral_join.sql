-- Lateral JOINs are very useful when you want to join a table with a subquery that depends on the table being joined.



SELECT 
	s.studentname, 
	g.course,
	g.grade
FROM students s,
LATERAL (
	SELECT *
	FROM grades 
	WHERE studentid=s.studentid
	) g