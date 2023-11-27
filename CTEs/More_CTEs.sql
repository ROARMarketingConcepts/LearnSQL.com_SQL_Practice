-- A salesman performs well if his total amount earned is above average 
-- amount earned in their city. We want to show which salesmen perform well.
-- For each salesman show their first_name, last_name and the third column 
-- named label, with either 'Above average' or 'Below average', based on the total 
-- amount earned by the salesman.

WITH total_amts AS

(
  SELECT salesman_id, first_name, last_name, c.name AS city, SUM(amount_earned) AS total_amt
	FROM daily_sales ds
	LEFT JOIN salesman s
	ON ds.salesman_id=s.id
	LEFT JOIN city c
	ON s.city_id=c.id
	GROUP BY 1,2,3,4
	ORDER BY 1,2,3,4
  
 ),
 
 city_avgs AS
 
 (
   SELECT city, AVG(total_amt) AS avg_amt
 	FROM total_amts
 	GROUP BY city
 ),
 
 summary_table AS 
 
 (
   SELECT first_name, last_name, ta.city, avg_amt, total_amt
 	FROM total_amts ta
 	LEFT JOIN city_avgs ca 
 	ON ta.city=ca.city
 )
 
 SELECT first_name, last_name,
 CASE 
 	WHEN total_amt>avg_amt 
    THEN 'Above average' 
    ELSE 'Below average' END AS label
 FROM summary_table
 
 
 
 


   
   