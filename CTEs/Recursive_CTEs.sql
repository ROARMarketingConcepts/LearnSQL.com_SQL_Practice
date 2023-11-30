-- 	In SQL, we talk about a recursive CTE when that CTE refers to itself. 
-- 	technically speaking, recursive CTEs do not use recursion, but iterations. 
--	Still, as the SQL keyword for this kind of queries is RECURSIVE, it is common 
--	to call such queries recursion. Treat it as some sort of convention rather than 
--	a technically accurate description.

-- Example: Count down from 20 to 5

WITH RECURSIVE counter (previous_value) AS (
  SELECT 20
  UNION ALL
  SELECT previous_value - 1
  FROM counter
  WHERE previous_value > 5
)

SELECT * 
FROM counter;


-- Show two columns. In the first column (column name previous_value), 
-- show numbers from one to ten. In the second column (column name previous_sum), 
-- show the total sum of all numbers so far.

WITH RECURSIVE counter(previous_value,previous_sum) AS (
  SELECT 1,1
  UNION ALL 
  SELECT counter.previous_value + 1, previous_sum+counter.previous_value+1
  FROM counter
  WHERE previous_value < 10
)

SELECT *
FROM counter;

-- Create a recursive query that will show three columns:

-- num – even numbers from 2 to 20,
-- num_plus_prev – that number plus the previous number,
-- num_square – the number squared.


WITH RECURSIVE maths(num,num_plus_prev, num_square) AS (
  SELECT 2,2,4
  UNION ALL 
  SELECT maths.num + 2, maths.num+maths.num+2, (maths.num+2)*(maths.num+2)
  FROM maths
  WHERE num < 20
)

SELECT *
FROM maths;


-- Complete the words CTE so that it generates all possible words made from those 
-- letters that have at most 5 letters. The shortest word should be an empty word ('').

-- The anchor member should be an empty string ''.

-- The recursive member should use the word you have so far and a new letter from letters. 
-- Use the concatenation symbol || to join new letters.

-- Remember about the termination check - use the function length(w) to that end.

WITH RECURSIVE letters(x) AS (
  SELECT 'a' UNION SELECT 'b'
),

words(w) AS (

SELECT ''
UNION 
SELECT w||x
FROM words,letters
WHERE length(w)<5

)

SELECT * FROM words;


-- We want to see each employee in the company with their data and the 
-- path from Boss to that person.


-- Create a new recursive CTE called hierarchy. The content of the boss CTE from the 
-- template should become the anchor member. Then, use UNION ALL and modify the external 
-- query from the template so that it uses recursion. Remember that the id of the superior 
-- must match the id that you got from the previous recursive step. Thanks to it, as the number 
-- of subordinates in our table is finite, the query will eventually stop. In other words, the termination 
-- check is not explicitly provided.

-- In the outer query, simply select all the information from your recursive CTE.
-- Don't forget that you start your recursive queries with WITH RECURSIVE.

WITH RECURSIVE hierarchy AS (
  SELECT
    id,
    first_name,
    last_name,
    superior_id,
    'Boss' AS path
  FROM employee
  WHERE superior_id IS NULL
  UNION ALL 
  SELECT
    employee.id,
    employee.first_name,
    employee.last_name,
    employee.superior_id,
    hierarchy.path || '->' || employee.last_name
  FROM employee, hierarchy
  WHERE employee.superior_id = hierarchy.id
)

SELECT *
FROM hierarchy;

----------------------------------------------------------

-- Use the boss's last_name instead of 'boss' for the path

WITH RECURSIVE hierarchy AS (
  SELECT
    id,
    first_name,
    last_name,
    superior_id,
    CAST(last_name AS text) AS path
  FROM employee
  WHERE superior_id IS NULL
  UNION ALL 
  SELECT
    employee.id,
    employee.first_name,
    employee.last_name,
    employee.superior_id,
    hierarchy.path || '->' || employee.last_name
  FROM employee, hierarchy
  WHERE employee.superior_id = hierarchy.id
)

SELECT *
FROM hierarchy;

-- Your task is to show the following columns:

-- id – ID of each department,
-- name – name of the department,
-- part_of – ID of the department one level up,
-- path – defined as all names from the root department until the given department, separated with slashes ('/').
-- Remember the root department has a NULL part_of id.

WITH RECURSIVE hierarchy AS (
  SELECT
    id,
    name,
    part_of,
    CAST(name AS text) AS path
  FROM department
  WHERE part_of IS NULL
  UNION ALL 
  SELECT
    department.id,
    department.name,
    department.part_of,
    hierarchy.path || '/' || department.name
  FROM department, hierarchy
  WHERE department.part_of= hierarchy.id
)

SELECT *
FROM hierarchy;

-- We want to visit every city starting from London. List all paths which start in London and 
-- visit all six cities in table city.

-- Show the following columns:

-- path – the list of consecutive cities separated by '->', e.g. London->Oxford->Cambridge...),
-- last_lat and last_lon coordinates of the last city in the path,
-- total_distance – how much we need to travel altogether,
-- count_places – a helper column that should show the number of cities in the path.
-- Order the results by the total_distance.

-- You can use the function lat_lon_distance(lat1,lon1,lat2,lon2) that we prepared for you 
-- to calculate the distance between two cities.

-- The london CTE should become your anchor member. The second part of the outer query should 
-- become the recursive member, but you need to construct the path column by referring to the path
-- from the previous recursive step. In the outer query, show only those paths where the number of 
-- cities equals 6 and order the rows in descending order by total_distance.

-- The last problem is how to construct the termination check. We can use the function position(a IN b),
-- which will return 0 if the string a is not contained in the string b. In other words, we only want to 
-- add a certain city if it didn't appear in the path so far.

WITH RECURSIVE travel(path,last_lat,last_lon,total_distance,count_places) AS 

(
  SELECT
      name::text AS path,
      lat, 
      lon, 
      0::float AS total_distance,
      1 AS count_places
  FROM city
  WHERE name = 'London' 
  UNION ALL
  SELECT
    t.path || '->' || c.name AS path,
    c.lat,
    c.lon,
    t.total_distance+lat_lon_distance(t.last_lat, t.last_lon, c.lat, c.lon) AS total_distance,
    t.count_places+1
FROM city c, travel t
WHERE position(c.name IN t.path)=0  
)

SELECT *
FROM travel
WHERE count_places = 6

------------------------------------------------------------------------------

-- This time, we're traveling between cities (table german_city with 
-- columns: id and name) in Germany and we don't calculate the distance using
-- a gps function. Instead, you are given a second table called road (columns: 
-- city_from, city_to, time) with average trip durations on a given route from one city to another.

-- Let's travel between the four cities starting in Berlin. Your task is to list the 
-- travel paths starting in Berlin and covering all four cities. Order the paths in 
-- descending order by total_time.

-- In your answer, provide the following columns:

-- path – city names separated by '-',
-- last_id – ID of the last city,
-- total_time – total time spent driving,
-- count_places – the number of places visited, should equal 4.

-- This one can be tough, so here is a hint: in the recursive member, you 
-- will have to join the recursive table you create with the table road, 
-- and the table german_city twice (one JOIN for city_from, the other one for city_to). 
-- In the termination check, use position(x IN path) = 0 to make sure that 
-- city x has not been visited so far.

WITH RECURSIVE travel (path, last_id,total_time,count_places) AS
  
 (SELECT 
      name::text AS path,
      id,
      0,
      1
  FROM german_city
  WHERE name = 'Berlin' 
  UNION ALL
  SELECT
    t.path||'-'||gc.name,
    gc.id,
    t.total_time+r.time,
    t.count_places+1
  FROM travel t 
  LEFT JOIN road r
    ON t.last_id=r.city_from
  LEFT JOIN german_city gc
    ON gc.id=r.city_to
  WHERE position(gc.name IN t.path)=0)
  
  SELECT *
FROM travel
WHERE count_places = 4
ORDER BY total_time ASC;


-- Show numeric values from 5 to 100 in increments of 5 (column value). As the second 
-- column (named sum), show the sum of all multiplications so far.

WITH RECURSIVE math_function (value, sum) AS (
  SELECT 5,5
  UNION ALL
  SELECT 
    value+5,
    sum+(value+5)
  FROM math_function
  WHERE value <100
)

SELECT *
FROM math_function

-- We want to travel between four cities presented in the table destination starting 
-- from Warsaw. We have another table called ticket which lists all possible flying connections 
-- for us. Your task is to find the path which will be cheapest in terms of the total tickets cost. 
-- List all paths starting in Warsaw which go through all four cities. Order the paths by 
-- descending total_cost.

-- In your answer, provide the following columns:

-- path – city names separated by '->',
-- last_id – ID of the last city,
-- total_cost – total cost of tickets,
-- count_places – the number of places visited, should equal 4.


WITH RECURSIVE travel (path, last_id,total_cost,count_places) AS
  
 (SELECT 
      name::text AS path,
      id,
      0,
      1
  FROM destination
  WHERE name = 'Warsaw' 
  UNION
  SELECT
    tr.path||'->'||d.name,
    d.id,
    tr.total_cost+t.cost,
    tr.count_places+1
  FROM travel tr 
  LEFT JOIN ticket t
    ON tr.last_id=t.city_from
  LEFT JOIN destination d
    ON d.id=t.city_to
  WHERE position(d.name IN tr.path)=0)
  
SELECT *
FROM travel
WHERE count_places = 4
ORDER BY total_cost DESC


-- Generate the Fibonacci sequence to 100


WITH RECURSIVE fibonacci(prev1, prev2) AS (
  SELECT 0, 1
  UNION ALL
  SELECT prev2, prev1 + prev2 AS fib_seq
  FROM fibonacci
  WHERE prev1 < 89
)
SELECT prev1 fib_seq
FROM fibonacci;
