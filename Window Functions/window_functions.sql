-- Okay. Let's jump into the brackets of OVER(...) and discuss the details. 
-- We'll start with ROWS, because they are a bit easier to explain than RANGE. 
-- The general syntax is as follows:

ROWS BETWEEN lower_bound AND upper_bound

-- You know BETWEEN already – it's used to define a range. So far, you've used it to define a range of values – 
-- this time, we're going to use it to define a range of rows instead. What are the two bounds? The bounds 
-- can be any of the five options:

-- UNBOUNDED PRECEDING – the first possible row.
-- PRECEDING – the n-th row before the current row (instead of n, write the number of your choice).
-- CURRENT ROW – simply current row.
-- FOLLOWING – the n-th row after the current row.
-- UNBOUNDED FOLLOWING – the last possible row.

-- The lower bound must come BEFORE the upper bound. In other words, a construction like: ...
ROWS BETWEEN CURRENT ROW AND UNBOUNDED PRECEDING 
--doesn't make sense and you'll get an error if you run it.

-- Take a look at the example below. The query computes:

-- the total price of all orders placed so far (this kind of sum is called a running total),
-- the total price of the current order, 3 preceding orders and 3 following orders.

SELECT
  id,
  total_price,
  SUM(total_price) OVER(ORDER BY placed ROWS UNBOUNDED PRECEDING) AS running_total,
  SUM(total_price) OVER(ORDER BY placed ROWS between 3 PRECEDING and 3 FOLLOWING) AS sum_3_before_after
FROM single_order
ORDER BY placed;

--For each product, show its id, name, introduced date and the count of products introduced up to that point.

SELECT id, name, introduced,
COUNT(id) OVER(ORDER BY introduced 
              ROWS BETWEEN UNBOUNDED PRECEDING AND 
              CURRENT ROW)
FROM product


-- Now, for each single_order, show its placed date, total_price, the average price calculated by 
-- taking 2 previous orders, the current order and 2 following orders (in terms of the placed date) 
-- and the ratio of the total_price to the average price calculated as before.

SELECT placed,total_price,
AVG(total_price) OVER(ORDER BY placed
                      ROWS BETWEEN 2 PRECEDING AND 2 FOLLOWING),
total_price/AVG(total_price) OVER(ORDER BY placed
                      ROWS BETWEEN 2 PRECEDING AND 2 FOLLOWING)
FROM single_order
