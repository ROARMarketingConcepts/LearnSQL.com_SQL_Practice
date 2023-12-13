-- Select the first name and last name of the clients who 
-- repurchased products (i.e., bought the same product in more 
-- than one order), together with the names of those products 
-- and the number of the orders they were part of (name 
-- that column 'order_count').

SELECT c.first_name,c.last_name, p.name, COUNT(p.name) AS order_count
FROM clients c
LEFT JOIN orders o
ON c.id=o.client_id
LEFT JOIN order_items oi
ON o.id=oi.order_id
LEFT JOIN products p
ON oi.product_id=p.id
GROUP BY 1,2,3
HAVING COUNT(p.name) >=2
