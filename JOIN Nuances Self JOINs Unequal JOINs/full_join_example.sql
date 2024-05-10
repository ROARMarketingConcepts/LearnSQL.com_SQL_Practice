-- For each course edition, display the students who have not passed the course in this edition. 
-- These are either students who have failed the course (passed is FALSE) or who haven’t passed 
-- the course yet (passed is NULL). If there are no non-passing students for the course edition, 
-- include the edition in the result anyway and show NULL in the student column.

-- Display the course title, the course edition ID, the student first and last name, and the passed column.

SELECT 
	c.title,
    ce.id,
    first_name,
    last_name,
    passed    
FROM course c
FULL JOIN course_edition ce
	on ce.course_id = c.id
FULL JOIN course_enrollment cen
	ON cen.course_edition_id = ce.id
FULL JOIN student s
	ON cen.student_id = s.id
WHERE passed IS FALSE OR passed IS NULL