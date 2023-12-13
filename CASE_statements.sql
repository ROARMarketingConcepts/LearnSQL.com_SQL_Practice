-- Display the play name and the category name (name the column with the category name tickets_sold_category).

-- tickets_sold_category is based on the total number of tickets sold for all events that staged a given play. 
-- The categories are as follows:

-- Less than or equal to 50 tickets sold – '50_or_less'.
-- More than 50 tickets and less than or equal to 100 tickets – '50_to_100'.
-- More than 100 tickets and less than or equal to 200 tickets – '100_to_200'.
-- More than 200 tickets – 'more_than_200'.


select name, --sum(tickets_sold),
case
	when sum(tickets_sold) <= 50 then '50_or_less'
    when sum(tickets_sold) <= 100  then '50_to_100'
    when sum(tickets_sold) <= 200 then '100_to_200'
    else 'more_than_200' end as tickets_sold_category
from event e
left join play p
on e.play_id=p.id
group by 1


-- Before we introduce free shipping to the USA and Canada, we'd 
-- ike to know how many orders are sent to these countries and how 
-- many are sent to other places. Take a look:

SELECT 
  CASE
    WHEN ship_country = 'USA' OR ship_country = 'Canada' THEN 0.0
    ELSE 10.0
  END AS shipping_cost,
  COUNT(*) AS order_count
FROM orders
GROUP BY
  CASE
    WHEN ship_country = 'USA' OR ship_country = 'Canada' THEN 0.0
    ELSE 10.0
  END;


-- In the SELECT clause, we used the CASE WHEN construction you've seen before. 
-- However, you can also see that the same CASE WHEN construction appears in the 
-- GROUP BY clause, only without the shipping_cost alias. Even though we already 
-- defined it in the SELECT clause and gave it an alias (shipping_cost), most 
-- databases don't allow referring to an alias in the GROUP BY clause (i.e., 
-- we can't write GROUP BY shipping_cost). That's why we had to repeat the whole 
-- construction. (Note that some databases, like PostgreSQL or MySQL, allow us to 
-- refer to column aliases in GROUP BY. However, this is a feature of these databases. 
-- The standard SQL doesn't allow it. It's best to know how to write the correct query 
-- in both cases.)


