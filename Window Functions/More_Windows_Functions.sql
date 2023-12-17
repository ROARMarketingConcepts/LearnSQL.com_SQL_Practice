-- We'd like to know which orders were the most expensive. Create a dense 
-- ranking of the orders based on their total_amount. The bigger the amount, 
-- the higher the order should be. If two orders have the same total_amount, 
-- the older order should go higher (you'll have to add another column order_date 
-- to the ordering). Name the ranking column rank.

-- Together with the ranking, show the ID of the order and its total amount.

SELECT order_id, total_amount, 
DENSE_RANK() OVER(ORDER BY total_amount DESC, order_date) AS rank
FROM orders
