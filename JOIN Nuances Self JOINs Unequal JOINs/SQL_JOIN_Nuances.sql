-- Display the menu item name along with the number of times it was sold as sales_count. 
-- Note that some menu items are new and may not have been sold yet. In that case, display 0 
-- ather than omit such menu items. Sort the results by sales_count in descending order.

-- Use a LEFT JOIN to include menu items that have not been sold yet.

-- Remember COUNT(*) and COUNT(column_name) behave differently. COUNT(*) counts all rows, 
-- while COUNT(column_name) counts only the rows where column_name is not NULL. In our case, 
-- if we use COUNT(*), the sales_count for menu items not yet sold will be 1 instead of 0! 
-- To get the correct result, use COUNT(purchase_menu_item.menu_item_id) instead.


SELECT mi.name, count(pmi.menu_item_id) AS sales_count
FROM menu_item mi
LEFT JOIN purchase_menu_item pmi
ON mi.id=pmi.menu_item_id
GROUP BY mi.name
ORDER BY sales_count DESC


-- For each month of 2023, calculate the total revenue and the revenue for 
-- each of the 'baked goods' and 'drinks' categories. Show the following columns: 
-- revenue_month, total_revenue, baked_goods_revenue, and drinks_revenue. Order the 
-- results by month.

SELECT DISTINCT EXTRACT(MONTH FROM purchase_date) AS revenue_month,
SUM(price) AS total_revenue,
SUM(CASE WHEN category='baked goods' THEN price ELSE 0 END) AS baked_goods_revenue,
SUM(CASE WHEN category = 'drinks' THEN price ELSE 0 END) AS drinks_revenue
FROM purchase p
LEFT JOIN purchase_menu_item pmi
	ON pmi.purchase_id=p.id
LEFT JOIN menu_item mi
	ON mi.id=pmi.menu_item_id
WHERE purchase_date > '2022-12-31'
GROUP BY EXTRACT(MONTH FROM purchase_date)


-- Show the speaker's name and the count of non-native languages spoken by each speaker 
-- (call this column language_count). Some speakers may not yet be assigned to any language; 
-- display 0 instead of omitting that speaker. Sort the results by the number of languages in 
-- descending order.

-- Use a LEFT JOIN to include speakers who have not yet chosen any non-native language. Remember 
-- that COUNT(*) and COUNT(column_name) behave differently. COUNT(*) counts all rows, whereas 
-- COUNT(column_name) counts only the rows in which the given column is not null. If we use COUNT(*) 
-- in our case, the number of languages shown for speakers with no non-native languages will be 1 rather than 0! 
-- To get the correct result, use COUNT(language_id) instead.

SELECT s.name,COUNT(ls.language_id) AS language_count
FROM speaker s
LEFT JOIN language_speaker ls
ON s.id=ls.speaker_id AND native='f'
GROUP BY 1
ORDER BY 2 DESC

-- Display the speaker's name and the count of chatrooms in which the speaker participates. 
-- Only count the chatrooms that have been active, defined by the last message sent in 2020 or later. 
-- Call this column chatroom_count. Sort the results by chatroom_count in descending order.

SELECT s.name, COUNT(c.id) AS chatroom_count
FROM speaker s
LEFT JOIN chatroom_speaker cs
ON cs.speaker_id=s.id 
LEFT JOIN chatroom c
ON c.id=cs.chatroom_id 
AND EXTRACT(year FROM last_active_at) >=2020  -- look at null rows in c.id that are generated
GROUP BY 1
ORDER BY 2 DESC

-- Display the speaker ID, the speaker's name, and the average lifetime of chatrooms for each speaker 
-- (avg_lifetime). The lifetime of a chatroom is the time between its creation and the last time when 
-- it was actively used (i.e., a message was sent by one of the users). If the average lifetime is NULL, 
-- we would like to display "0 days". Sort the results by the average lifetime in descending order.

SELECT s.id,s.name, AVG(COALESCE(last_active_at-created_at,'0 days')) AS avg_lifetime
FROM speaker s
LEFT JOIN chatroom_speaker cs
ON cs.speaker_id=s.id 
LEFT JOIN chatroom c
ON c.id=cs.chatroom_id 
GROUP BY 1,2
ORDER BY avg_lifetime DESC

-- There is one more caveat when using LEFT JOIN and its friends. There is a subtle difference 
-- between the conditions in the ON and WHERE clauses for these JOINs. The ON condition is evaluated 
-- when the tables are joined. The WHERE condition is applied after the rows have been joined. Take a 
-- look at this example:

SELECT
  course.name,
  lecturer.name
FROM course
LEFT JOIN lecturer
  ON course.lecturer_id = lecturer.id
WHERE lecturer.id = 3

-- The query will list all courses but only those that are taught by the lecturer with id = 3. 
-- Other courses will not have lecturer information listed, even if there is a lecturer assigned to them.

SELECT *
FROM subject
LEFT JOIN lecturer
  ON subject.lecturer_id = lecturer.id
  AND lecturer.id = 3

-- Note that for INNER JOINs conditions in the ON and WHERE clauses are effectively the same.

-- For products that weren't sold even once between 2015-02-01 and 2015-02-05, 
-- show the product name (rename the column to product_name), it's price and the 
-- producer's name (rename the column to company_name). You should display all products 
-- that haven't been sold in this interval, also the ones that don't belong to any company.


-- First you have to LEFT JOIN the sales_history to the product table. Mind that we are interested 
-- ONLY in products sold BETWEEN the 2015-02-01 AND 2015-02-05 so we need to add filtering before 
-- the LEFT JOIN as applied:

-- AND date BETWEEN '2015-02-01' AND '2015-02-05'

-- Then we can safely join the producer table. We'd like to display all products, 
-- even the ones that belong to no company, so we need to use LEFT JOIN.

-- However, mind that we wanted to return the name of products that weren't sold 
-- on that day, so we have to apply one final condition:

-- WHERE sh.product_id IS NULL

SELECT 
    p.name AS product_name,
  price,
    pr.name AS company_name
    
FROM product p
LEFT JOIN department d
ON p.department_id=d.id
LEFT JOIN sales_history s
ON s.product_id=p.id
AND date BETWEEN '2015-02-01' AND '2015-02-05'
LEFT JOIN producer pr
ON pr.id=p.producer_id
LEFT JOIN nutrition_data n
ON n.product_id=p.id
 AND pr.name IS NULL
WHERE s.product_id IS NULL

Show the name and price of each product in the 'fruits' and 'vegetables' 
departments. Consider only those products that are not produced by 'GoodFoods'.

SELECT p.name,price
    
FROM product p
LEFT JOIN department d
  ON p.department_id=d.id
LEFT JOIN producer pr
  ON pr.id=p.producer_id
WHERE d.name IN ('fruits','vegetables') 
  AND (pr.name != 'GoodFoods' OR pr.name IS NULL)


-- List all pairs of full siblings. Full siblings are people who have 
-- the same mother and the same father. Name the columns with sibling 
-- names younger_sibling and older_sibling (use column year_born to identify who is younger).

-- You can assume that in our database no two siblings were born in the same year 
-- and there are no more than two siblings per family.

SELECT ys.name AS younger_sibling, os.name AS older_sibling
FROM person ys
LEFT JOIN person os
  ON ys.mother_id=os.mother_id 
    AND os.father_id=ys.father_id
WHERE ys.year_born > os.year_born

-- For each group, show its ID (as group_id), language, and level, together with the ID of the room 
-- they're in and the days when they have lectures. Consider only those groups whose lectures are always 
-- held in the same room.

SELECT t1.group_id,sg.language,group_level,t1.room_id,t1.day
FROM timetable t1
LEFT JOIN timetable t2
  ON t1.group_id=t2.group_id
LEFT JOIN student_group sg
  ON sg.id=t1.group_id
WHERE t1.room_id=t2.room_id
  AND t1.day <> t2.day


