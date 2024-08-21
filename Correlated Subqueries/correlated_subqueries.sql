-- Select the name of each orchestra that held a 
-- concert in its country of origin in 2003.

--In the outer query select the name of the orchestra. 
--In WHERE of the outer query use IN and a correlated subquery.

---WHERE country_origin IN (...)

--In the subquery, select country names for concerts where a given 
--orchestra performed in 2003. Remember to refer to the orchestras in the subquery.

SELECT name
FROM orchestras o
WHERE country_origin IN
	(SELECT country
	FROM concerts c
	WHERE c.year=2003 AND o.id=c.orchestra_id)


-- Correlated subqueries can be used to find the best object in a certain category. 
-- Here we select orchestras which have the best rating among orchestras coming from the same city:

SELECT
  name,
  city_origin,
  rating
FROM orchestras o1
WHERE rating = 
	(SELECT
    	MAX(rating)
  	FROM orchestras o2
  	WHERE o1.city_origin = o2.city_origin)

-- In the subquery, we select the maximum rating for all orchestras which come from 
-- the same city as the orchestra in the outer query. Note that we use aliases o1, o2 
-- to distinguish between subquery orchestra and outer query orchestra. In the outer query 
-- we select orchestras which have rating equal to the rating found in the subquery.

----------------------------------------------------------------------------------------------

-- Select the name, wage, and experience of all members who earned the most within each orchestra.

--The query is similar to the example above. In the subquery select the maximal wage for 
--all members coming from the orchestra as the member in the outer query. Use the = operator 
--to select members with the same wage.


SELECT name,wage,experience
FROM members m1
WHERE wage = 
	(SELECT
    	MAX(wage)
  	FROM members m2
  	WHERE m1.orchestra_id = m2.orchestra_id)


--Show the names of the most experienced members of each 
--orchestra and the name of that orchestra. Rename the columns 
--to member and orchestra, respectively.

SELECT m1.name AS member,o.name AS orchestra
FROM members m1
LEFT JOIN orchestras o
ON m1.orchestra_id=o.id
WHERE experience = 
	(SELECT
    	MAX(experience)
  	FROM members m2
  	WHERE m1.orchestra_id = m2.orchestra_id)


--Show name of orchestra members who earn more than the 
--average wage of the violinists from their orchestra.

SELECT name
FROM members m1
WHERE wage > 
	(SELECT
    	AVG(wage)
  	FROM members m2
  	WHERE m1.orchestra_id = m2.orchestra_id 
    AND m2.position='violin')


--Select the name, rating, city of origin, and the total 
-- number of concerts it held in Ukraine for each orchestra 

--Hint:

-- First, select the name, rating, and city of origin for each orchestra 
-- from Germany (no need for a subquery here). Then, add a correlated subquery 
-- in the SELECT clause, which will count the number of concerts held in Ukraine 
-- by the given orchestra.

--An example of a correlated subquery in SELECT looks like this:
--This query finds the name of the cat together with the average age 
--of all cats with the same name.

SELECT 
   name, 
   (SELECT AVG(age) FROM cats c2 WHERE c2.name = c1.name)
FROM cats c1

--------------------------------------------------------------------------------

SELECT name,rating,city_origin,
	(SELECT COUNT(*)
	FROM concerts c
	WHERE country='Ukraine'
	AND o.id=c.orchestra_id)
FROM orchestras o
WHERE o.country_origin='Germany'


--For each orchestra show the name of the orchestra, the name of the city where the 
--orchestra received the highest rating for its performance, and the rating.


--Use correlated subqueries. In the subquery select the highest rating received by the orchestra. 
--Use the subquery in WHERE to filter concerts when the orchestra was given this rating.

SELECT o.name, c.city, c.rating
FROM concerts c
LEFT JOIN orchestras o
ON c.orchestra_id=o.id
WHERE c.rating IN
	(SELECT MAX(c.rating)
	FROM concerts c
	WHERE c.orchestra_id=o.id)

--For each instrument, show its type, maker, the owner's name, the corresponding orchestra name, 
--and the number of concerts (name this column as concert_number) in which the owner played from 
--2013 to 2016. Take into consideration only instruments produced in 2013 or earlier.

--First select the type, maker, the owner's name, and the corresponding orchestra name for each 
--instrument produced in 2013 or earlier (no need for a subquery). Then add a correlated subquery 
--to compute the number of concerts the owner played between 2013 and 2016.

--The structure of the query is similar to the final query from the previous part (German orchestras in Ukraine):

-- SELECT 
--   name,
--   rating,
--   city_origin,
--   (SELECT
--     COUNT(*)
--   FROM concerts
--   WHERE orchestras.id = concerts.orchestra_id AND country = 'Ukraine') AS count
-- FROM orchestras
-- WHERE country_origin = 'Germany'


SELECT i.type,i.maker,m.name,o.name,
	(SELECT COUNT(c.orchestra_id)     
	FROM concerts c                    
	WHERE year BETWEEN 2013 AND 2016
    AND c.orchestra_id=o.id) AS concert_number   -- get separate counts for each orchestra_id
FROM instruments i
LEFT JOIN members m
ON i.owner_id=m.id
LEFT JOIN orchestras o
ON m.orchestra_id=o.id
WHERE i.production_year<=2013

-- For each course edition find the minimum passing final grade. Display the following columns:

-- the calendar year,
-- the term,
-- the course title,
-- the minimum passing final grade, that is the minimum final grade for the students that passed this course (name the column minimum_passing).
-- Order the results by the calendar_year, term, and course title.

SELECT
 calendar_year,
 term,
 title,
 (SELECT MIN(final_grade)
  FROM course_enrollment
  WHERE course_enrollment.course_edition_id = c_en.course_edition_id
    AND passed IS TRUE
  GROUP BY course_edition_id) AS minimum_passing
FROM course_enrollment AS c_en
JOIN course_edition AS c_ed
  ON c_en.course_edition_id = c_ed.id 
JOIN course AS c
  ON c.id = c_ed.course_id
JOIN academic_semester AS a_s
  ON c_ed.academic_semester_id = a_s.id
GROUP BY 3,2,1, course_edition_id
ORDER BY 3,2,1;