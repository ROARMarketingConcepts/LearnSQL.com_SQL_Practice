-- We'd like to know which orders were the most expensive. Create a dense 
-- ranking of the orders based on their total_amount. The bigger the amount, 
-- the higher the order should be. If two orders have the same total_amount, 
-- the older order should go higher (you'll have to add another column order_date 
-- to the ordering). Name the ranking column rank.

-- Together with the ranking, show the ID of the order and its total amount.

SELECT order_id, total_amount, 
DENSE_RANK() OVER(ORDER BY total_amount DESC, order_date) AS rank
FROM orders


-- Select all the products. For each row, show the name of the category to which 
-- roduct belongs (category_name), the name of the product (product_name), the price 
-- of the product (unit_price), the name of the least expensive product in the category 
-- (name the column least_expensive_product), and the price of the least expensive product 
-- in the category (name the column smallest_unit_price).

-- Use the LAST_VALUE() function, and don't forget to specify the window frame!

SELECT category_name,product_name,unit_price,
LAST_VALUE(product_name) OVER(PARTITION BY category_name 
                            ORDER BY unit_price DESC 
                           	ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS least_expensive_product,
MIN(unit_price) OVER(PARTITION BY category_name) AS smallest_unit_price
FROM products p
LEFT JOIN categories c
ON c.category_id=p.category_id

-- Display the category name and the name of the top-selling product in each category. 
-- Base the ranking on the total quantity of the product sold across all orders. Name the 
-- columns: category_name, product_name. Treat the products with the same name but different 
-- color as one product. If there are a few products with the same total quantity in a category, 
-- display all such products.

WITH rankings AS 

(SELECT c.name AS category_name, p.name AS product_name, 
DENSE_RANK() OVER(PARTITION BY c.name ORDER BY SUM(quantity) DESC) AS rank
FROM order_item oi
LEFT JOIN product p
ON oi.product_id=p.id
LEFT JOIN category c
ON p.category_id=c.id
GROUP BY 1,2)

SELECT category_name,product_name 
FROM rankings
WHERE rank=1

-- For each date, find the running average of the total revenue for the surrounding 7 days. Display:

-- order_date (name the column date)
-- The total revenue earned on this date (name the column total_price)
-- the average revenue for the surrounding 7-day period that includes the 3 preceding and 3 following days (name the column average_revenue). Round the result to two decimal places.
-- Sort the results by date.


WITH cte AS (
  SELECT
    o.order_date,
    SUM(p.price * oi.quantity) AS total_price
  FROM products p
  JOIN order_items oi
    ON p.id = oi.product_id
  JOIN orders o
    ON oi.order_id = o.id
  GROUP BY
    o.order_date
)

SELECT
  order_date,
  total_price,
  ROUND(AVG(total_price) OVER (ORDER BY order_date
    RANGE BETWEEN INTERVAL '3' DAY PRECEDING AND INTERVAL '3' DAY FOLLOWING), 2) AS average_revenue
FROM cte
ORDER BY order_date;


-- For each country having an athlete running a 200 meter distance, display:

-- country_name
-- result – the best time result in a 200 meter run, in a given country.
-- last_name – the last name of the athlete who got this result.
-- first_name – their first name.
-- race_date – the date of the race in which the result was achieved.

SELECT DISTINCT
  country_name,
    FIRST_VALUE(result) OVER(PARTITION BY nationality.id ORDER BY result) AS result,
    FIRST_VALUE(last_name) OVER(PARTITION BY nationality.id ORDER BY result) AS last_name,
    FIRST_VALUE(first_name) OVER(PARTITION BY nationality.id ORDER BY result) AS first_name,
    FIRST_VALUE(race_date) OVER(PARTITION BY nationality.id ORDER BY result) AS race_date
FROM nationality
JOIN athlete
  ON nationality.id = athlete.nationality_id
JOIN result
  ON athlete.id = result.athlete_id
JOIN race
  ON race.id = result.race_id
JOIN round
  ON round.id = race.round_id
JOIN event
  ON event.id = round.event_id
JOIN discipline
  ON discipline.id = event.discipline_id
WHERE distance=200





