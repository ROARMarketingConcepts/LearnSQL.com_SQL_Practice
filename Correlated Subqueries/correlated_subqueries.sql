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

SELECT 
   name, 
   (SELECT AVG(age) FROM cats c2 WHERE c2.name = c1.name)
FROM cats c1

--This query finds the name of the cat together with the average age of all cats with the same name.

SELECT name,rating,city_origin,
	(SELECT COUNT(*)
	FROM concerts c
	WHERE country='Ukraine'
	AND o.id=c.orchestra_id)
FROM orchestras o
WHERE o.country_origin='Germany'

