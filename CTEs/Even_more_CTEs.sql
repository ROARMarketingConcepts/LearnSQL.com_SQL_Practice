-- We define 'Good' salespeople as those whose total amount earned is above the average 
-- amount earned in their city.  We want to compare the average number of items sold between two groups: 
-- the 'Good' salespeople and the 'Bad' salespeople.

-- Adding a comment

WITH good_bad AS 

(SELECT salesman_id, c.name AS city, SUM(amount_earned) AS total_amount_earned,
	AVG(SUM(amount_earned)) OVER(PARTITION BY c.name) AS city_average,
    CASE WHEN SUM(amount_earned)>AVG(SUM(amount_earned)) 
    	OVER(PARTITION BY c.name) THEN 'Good' ELSE 'Bad' END AS label 
FROM daily_sales ds
LEFT JOIN salesman s
ON ds.salesman_id=s.id
LEFT JOIN city c
ON s.city_id=c.id
GROUP BY 1,2
ORDER BY 2,1),

items_sold AS 

(SELECT ds.salesman_id, label, SUM(items_sold) AS total_items
FROM daily_sales ds
LEFT JOIN good_bad gb
ON ds.salesman_id=gb.salesman_id
GROUP BY 1,2)

SELECT label, AVG(total_items) AS average
FROM items_sold
GROUP BY 1