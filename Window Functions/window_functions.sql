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

--You may wonder what the default window frame is when it's not explicitly specified. 
--This may differ between databases, but the most typical rule is as follows:

--If you don't specify an ORDER BY clause within OVER(...), the whole partition of 
--rows will be used as the window frame.

--If you do specify an ORDER BY clause within OVER(...), the database will assume 
--RANGE UNBOUNDED PRECEDING as the window frame. 

--For each row sorted by the year, show its department_id, year, amount, the average 
--amount from all departments in the given year and the difference between the amount and the average amount.

SELECT department_id,year,amount,
AVG(amount) OVER(ORDER BY year RANGE CURRENT ROW),
amount-AVG(amount) OVER(ORDER BY year RANGE CURRENT ROW)
FROM revenue

-- Take the statistics for website_id = 1. For each row, show the day, 
-- the number of clicks on that day and the median of clicks in May 2016 
-- (calculated as the 16th value of all 31 values in the column clicks when 
-- sorted by the number of clicks).

SELECT day, clicks, 
NTH_VALUE(clicks,16) OVER(ORDER BY clicks
    ROWS BETWEEN UNBOUNDED PRECEDING
      AND UNBOUNDED FOLLOWING)
FROM statistics
WHERE website_id=1


-- For each row, show the following columns: 
-- store_id, day, customers and the number of clients 
-- in the 5th greatest store in terms of the number of 
-- customers on that day.

SELECT store_id,day,customers,
NTH_VALUE(customers,5) OVER(PARTITION BY day ORDER BY customers DESC 
                           ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)
FROM sales


-- For each day, show the following two columns: day and the name of the 
-- second most frequently repaired phone on that day. Only take into account free_repairs.

WITH repairs_ranking AS

(SELECT day,phone,
RANK() OVER(PARTITION BY day ORDER BY free_repairs DESC)
FROM repairs)

SELECT day, phone
FROM repairs_ranking
WHERE rank=2

-- For each phone, show the following information: phone, 
-- day, revenue and the revenue for the first repair for each 
-- phone (column name first_revenue)

SELECT phone,day,revenue,
FIRST_VALUE(revenue) OVER(PARTITION BY phone ORDER BY day) AS first_revenue
FROM repairs


-- Show the order date, the total value of the orders placed on that day 
-- (as the daily_sum column) and the running average of the revenue from the 
-- previous 6 days and the current day (as the running_average column). Round 
-- this average to two decimal places. Sort the orders from the oldest to the most recent.

SELECT order_date,SUM(total_amount) AS daily_sum,
ROUND(AVG(SUM(total_amount)) OVER(ORDER BY order_date ROWS BETWEEN
                             6 PRECEDING AND CURRENT ROW),2) AS running_average
FROM orders
GROUP BY order_date
ORDER BY 1


-- For each country, show the:
-- Country name.
-- Year of registration (name this column registration_year).
-- Number of new customers from this country that joined that year (name this column new_customers_count).
-- Running total of the customers from this country that registered in the current or previous years (name this column running_total).
-- Number of registered users from this country the year its first user registered (name this column first_year).
-- Number of registered users from that country in the last year (name this column last_year).
-- To get year from the registration_year, use:

-- EXTRACT(year FROM registration_date)

WITH running_totals AS 

(SELECT DISTINCT country,EXTRACT(YEAR FROM registration_date) AS registration_year,
COUNT(customer_id) AS new_customers_count,
SUM(COUNT(customer_id)) OVER(PARTITION by country 
                             ORDER BY EXTRACT(YEAR FROM registration_date) 
                             RANGE UNBOUNDED PRECEDING) AS running_total
FROM customers
GROUP BY 1,2
ORDER BY 1,2)

SELECT country,registration_year,new_customers_count,running_total,
FIRST_VALUE(new_customers_count) OVER(PARTITION BY country ORDER BY registration_year) AS first_year,
LAST_VALUE(new_customers_count) OVER(PARTITION BY country ORDER BY registration_year 
                              ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS last_year
FROM running_totals



-- Divide the books into 4 groups based on their rating. For each group (bucket), 
-- show its number (column bucket), the minimal and maximal rating in that bucket.


WITH ratings_quartiles AS
(SELECT rating, NTILE(4) OVER(ORDER BY rating) AS bucket
FROM book
ORDER BY rating)

SELECT bucket,MIN(rating),MAX(rating)
FROM ratings_quartiles
GROUP BY bucket
ORDER BY bucket

-- Show:

-- distinctive amount_worth values of giftcards,
-- count of the number of giftcards with this value that were 
-- ever purchased (shown as count_1),
-- count of all giftcards ever purchased (shown as count_2),
-- show the percentage that the respective giftcard type constitutes in relation 
-- to all gift cards. Show the last column rounded to integer values and name it percentage.


SELECT DISTINCT amount_worth, 
COUNT(id) OVER(PARTITION BY amount_worth) AS count_1,
COUNT(id) OVER() AS count_2,
ROUND(CAST(COUNT(id) OVER(PARTITION BY amount_worth) AS numeric)/COUNT(id) OVER()*100,0) AS percentage
FROM giftcard
ORDER BY amount_worth

