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


-- For each article, select the:

-- url – the article URL.
-- title – the article title.
-- name – the category name.
-- total_article_views – the total number of views.
-- total_category_views – the total number of views for that category across all articles.
-- article_views_to_category_views_percentage – the percentage ratio of the article views 
-- to all the views in its category. Round the values in this column to two decimal points.
-- Take into consideration only views from May 2020.

-- Order the result alphabetically by category name. If a category has multiple articles, 
-- order them so that the most popular articles are listed first, and then order them by article URL (in ascending order).

SELECT
  a.url,
  a.title,
  ac.name,
  SUM(art.views) AS total_article_views,
  SUM(SUM(art.views)) OVER(PARTITION BY ac.id) AS total_category_views,
  ROUND(SUM(art.views)*100.0/
        SUM(SUM(art.views)) OVER(PARTITION BY ac.id), 2) AS article_views_to_category_views_percentage
FROM article a
JOIN article_category ac
  ON ac.id = a.article_category_id
JOIN article_traffic art
  ON art.url = a.url
WHERE art.day BETWEEN '2020-05-01' AND '2020-05-31'
GROUP BY
  a.url,
  a.title,
  ac.id,
  ac.name
ORDER BY
  ac.name,
  total_article_views DESC,
  a.url;



-- For all articles, select:

-- url – the article URL.
-- title – the article title.
-- publication_date – the publication date.
-- day – the traffic day.
-- days_from_publication – the difference, in days, between the traffic day and the publication date, e.g., 3 days.
-- views – the number of views on the given day.
-- views_percentage_increase – the percent increase of the views since the previous day, rounded to two decimal points.
-- accumulated_views_percentage – the percentage of the article's total views made up by all the given article's 
-- views to the current traffic day, rounded to two decimal points.


SELECT 
  a.url,
  a.title,
  a.publication_date,
  day,
  day-publication_date AS days_from_publication,
  views,
  ROUND(100*views/SUM(views) OVER(PARTITION BY a.url ORDER BY a.publication_date
                ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING),2) AS views_percentage_increase,
  ROUND(SUM(views) OVER(PARTITION BY a.url ORDER BY a.publication_date
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)*100  /
      SUM(views) OVER(PARTITION BY a.url), 2) AS accumulated_views_percentage
FROM article a
LEFT JOIN article_traffic art
ON a.url=art.url

-- For each author, show:

-- last_name – the last name.
-- first_name – the first name.
-- worst_articles – the number of worst articles by the author across all categories. 
-- he worst articles are the ones that have placed in the bottom five for their category 
-- in terms of views within 30 days of publication.
-- best_articles – the number of best articles by the author across all categories. 
-- The best articles are the ones that have placed in the top five for their category 
-- in terms of views within 30 days of publication.
-- total_articles – the total number of articles they've written.
-- Take into consideration only articles published on or before 2020. When creating a 
-- ranking, use a RANK() function.

-- To make sure the two dates differ by less than 30 days, make sure the dates difference is less than INTERVAL '30 days'.

WITH article_views_in_month AS 

(
  SELECT
    a.url,
    a.title,
    a.author_id,
    a.article_category_id,
    SUM(art.views) AS total_views_in_month
  FROM article a
  JOIN article_traffic art
    ON a.url = art.url
  WHERE art.day - a.publication_date < INTERVAL '30 days'
    AND a.publication_date <= '2020-12-31'
  GROUP BY 1,2,3,4
  
  ),

worst_articles_in_categories AS 

(
  SELECT
    RANK() OVER(PARTITION BY article_category_id
          ORDER BY total_views_in_month ASC) AS rank,
    url,
    title,
    author_id,
    article_category_id,
    total_views_in_month
  FROM article_views_in_month
),

best_articles_in_categories AS (
  SELECT
    RANK() OVER(PARTITION BY article_category_id
            ORDER BY total_views_in_month DESC) AS rank,
    url,
    title,
    author_id,
    article_category_id,
    total_views_in_month
  FROM article_views_in_month
)

SELECT a.first_name, a.last_name,
COUNT(CASE WHEN w.rank <= 5 THEN w.url END) AS worst_articles,
COUNT(CASE WHEN b.rank <= 5 THEN b.url END) AS best_articles,
COUNT(*) AS total_articles
FROM author a
JOIN worst_articles_in_categories w
  ON a.id = w.author_id
JOIN best_articles_in_categories b
  ON a.id = b.author_id
AND w.url=b.url  -- get best / worst ranking for each article url
GROUP BY 1,2