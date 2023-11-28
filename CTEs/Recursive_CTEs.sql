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
