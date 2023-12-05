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



