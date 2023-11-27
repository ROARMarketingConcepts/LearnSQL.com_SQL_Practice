--For each statistics row with website_id = 2, show the day, the RPM and the RPM 7 days later. 
--Rename the columns to RPM and RPM_7.s:

SELECT day,
(revenue/impressions)*1000 AS RPM,
LEAD(revenue/impressions,7) OVER(ORDER BY day)*1000 AS RPM_7
FROM statistics
WHERE website_id=2