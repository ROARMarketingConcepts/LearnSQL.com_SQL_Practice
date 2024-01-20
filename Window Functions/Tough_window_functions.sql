-- For each author, show:

-- Their id.
-- Their last name.
-- Their first name.
-- The name of the category in which they've published articles.
-- The day.
-- The total views in the given category on that day (name the column article_views_by_day_and_category).
-- The total views on that day for that author across all the categories (name the column article_views_by_day).
-- The total accumulated views by the author from the day they published their first article up to the current 
-- day for the given category (name the column accumulated_article_views_by_category).
-- Order the results so that the authors are in alphabetical order by last name, then by first name. 
-- If there are multiple rows for the same author, order the rows by the category in ascending order 
-- nd by the day so that the most recent day is first.

SELECT
  au.id,
  au.last_name,
  au.first_name,
  ac.name,
  atr.day,
  SUM(atr.views) AS article_views_by_day_and_category,
  SUM(SUM(atr.views)) OVER(
    PARTITION BY au.id,
    atr.day
  ) AS article_views_by_day,
  SUM(SUM(atr.views)) OVER(
    PARTITION BY au.id,
    ac.id
    ORDER BY atr.day
    RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
  ) AS accumulated_article_views_by_category
FROM author au
LEFT JOIN article ar
  ON au.id = ar.author_id
LEFT JOIN article_traffic atr
  ON ar.url = atr.url
LEFT JOIN article_category ac
  ON ac.id = ar.article_category_id
GROUP BY
  au.id,
  au.first_name,
  au.last_name,
  atr.day,
  ac.name,
  ac.id
ORDER BY
  au.last_name,
  au.first_name,
  ac.name,
  atr.day DESC;


-- For each author, select:

-- id – their ID.
-- Their last name.
-- Their first name.
-- The day.
-- The author's total article views for that day (name the column article_views_by_day).
-- The author's total accumulated article views up to the given day (name the column article_views_accumulated).
-- Then, for each of these three categories ...

-- Small Dogs
-- Puppies
-- Dog Health
-- ... show two columns:

-- The total article views for a given author on a given day for that category.
-- The accumulated article views for a given author up to that day for that category.
-- You'll get six columns. Name them:

-- small_dogs_by_day
-- small_dogs_accumulated
-- puppies_by_day
-- puppies_accumulated
-- dog_health_by_day
-- dog_health_accumulated
-- Finally, order the result by day so that the most recent 
-- values are first, and then by the author last name and first 
-- name in ascending order.

SELECT DISTINCT
  au.id,
  au.last_name,
  au.first_name,
  atr.day,
  SUM(atr.views) OVER(PARTITION BY au.id,atr.day) AS article_views_by_day,
  SUM(atr.views) OVER(PARTITION BY au.id ORDER BY atr.day
            RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS article_views_accumulated,                 
  SUM(CASE WHEN ac.name='Small Dogs' THEN atr.views END) OVER(PARTITION BY au.id,atr.day) AS small_dogs_by_day,
  SUM(CASE WHEN ac.name='Small Dogs' THEN atr.views END) OVER(PARTITION BY au.id ORDER BY atr.day
            RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS small_dogs_accumulated,
  SUM(CASE WHEN ac.name='Puppies' THEN atr.views END) OVER(PARTITION BY au.id,atr.day) AS puppies_by_day,
  SUM(CASE WHEN ac.name='Puppies' THEN atr.views END) OVER(PARTITION BY au.id ORDER BY atr.day
            RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS puppies_accumulated,
  SUM(CASE WHEN ac.name='Dog Health' THEN atr.views END) OVER(PARTITION BY au.id,atr.day) AS dog_health_by_day,
  SUM(CASE WHEN ac.name='Dog Health' THEN atr.views END) OVER(PARTITION BY au.id ORDER BY atr.day
            RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS dog_health_accumulated
FROM author au
LEFT JOIN article ar
  ON au.id = ar.author_id
LEFT JOIN article_traffic atr
  ON ar.url = atr.url
LEFT JOIN article_category ac
  ON ac.id = ar.article_category_id
ORDER BY 4 DESC,2,3


