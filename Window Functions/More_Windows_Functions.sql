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