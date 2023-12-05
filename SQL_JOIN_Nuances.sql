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
