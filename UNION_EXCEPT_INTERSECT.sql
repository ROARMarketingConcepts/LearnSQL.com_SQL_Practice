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