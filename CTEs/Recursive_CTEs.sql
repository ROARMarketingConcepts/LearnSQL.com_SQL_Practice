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
