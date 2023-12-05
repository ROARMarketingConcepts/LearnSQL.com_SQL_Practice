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
