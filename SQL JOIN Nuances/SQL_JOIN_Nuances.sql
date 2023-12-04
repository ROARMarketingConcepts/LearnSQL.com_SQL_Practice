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