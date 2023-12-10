-- We can use any condition to join two tables, such as comparison operators 
-- (<, >, <=, >=, !=, <>), the BETWEEN operator or any other logical condition to join tables.

-- NON-EQUI self JOINs

-- The non-equi JOIN comes in handy especially when you have to join a table with itself. 
-- For example you can select all the items from a table and pair them, either in unique or non-unique pairs.
-- Suppose you have the items table, and you want to find all possible combinations of all item pairs 
-- for a special promotion. You would like to show all possible pairs, excluding only the case when a given 
-- item matches itself (that is, the pair consists of two copies of the same item):

SELECT
  item1.name,
  item2.name
FROM items item1
JOIN items item2
  ON item1.id != item2.id


-- Great! Everything works... However, with this query, we don't get unique pairs - 
-- because the result also includes pairs in reverse order. What about unique pairs? 
-- Well, in that case, we have to change the inequality operator to the less-than operator (<):

SELECT
  item1.name,
  item2.name
FROM items item1
JOIN items item2
  ON item1.id < item2.id

-- Why? Suppose we have only three items in the items table. The item with the smallest ID (id = 1) 
-- can be listed as the first element of two pairs: 1 & 2 and 1 & 3. But because of the less-than operator, 
-- the item with id = 2 can only be listed together with item 3. And the item with id = 3 is never listed as 
-- the first member of a pair. With this little trick, we have unique pairs!

-------------------------------------------------------------------------------------------------------------

-- Show the name of each treatment and the first and last names of the patients to whom it was recommended for 
-- all therapies recommended by physicians with the surname Core or Calderwood. Also, show only patients with odd ID numbers.

SELECT tr.name,pa.first_name,pa.last_name
FROM therapy th
LEFT JOIN patient pa
	ON th.patient_id=pa.id
LEFT JOIN physician ph
	ON ph.id=th.physician_id
LEFT JOIN treatment tr
	ON th.treatment_type=tr.type
WHERE ph.last_name IN ('Core','Calderwood') 
	AND MOD(pa.id,2)=1   -- odd patient ids


-- For each buyer with funds less than 8000, show their name together 
-- with the names of all paintings and sculptures that are outside of 
-- their price range.

SELECT b.name,i.name
FROM buyer b
INNER JOIN item i
ON i.price > b.funds
AND b.funds<8000
AND i.type IN ('sculpture','painting')