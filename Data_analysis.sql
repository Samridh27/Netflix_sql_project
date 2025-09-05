DROP TABLE IF EXISTS netflix;

CREATE TABLE netflix (
	show_id	VARCHAR(6),
	type	VARCHAR(10),
	title	VARCHAR(150),
	director	VARCHAR(208),
	casts	VARCHAR(1000),
	country	VARCHAR(150),
	date_added	VARCHAR(50),
	release_year INT,	
	rating	VARCHAR(10),
	duration	VARCHAR(15),
	listed_in	VARCHAR(100),
	description VARCHAR(250)
);

SELECT * FROM netflix;

SELECT COUNT(*) AS TOTAL FROM netflix;

SELECT DISTINCT type FROM netflix;

-- business problems

-- count number of movies vs tv shows

SELECT type, COUNT(*) as total_content FROM netflix GROUP BY type;

-- Find the most ratings for movies and tv shows
SELECT 
	type,
	rating
FROM
(
	SELECT
		type,
		rating,
		COUNT(*),
		RANK() OVER(PARTITION BY type ORDER BY COUNT(*) DESC) as ranking
	FROM netflix
	GROUP BY 1,2
) as t1
WHERE 
	ranking = 1

-- List all the movies released in a specific year (eg. 2020)

SELECT * FROM netflix WHERE type = 'Movie' AND release_year = 2020;

-- Find the top 5 countries having most content on netflix

SELECT
	UNNEST(STRING_TO_ARRAY(country,',')) as new_country,
	COUNT(show_id) as total_count
FROM netflix
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;

-- Identify the longest movie

SELECT * FROM netflix
WHERE
	type = 'Movie'
	AND
	duration = (SELECT MAX(duration) FROM netflix)

-- Find content added in last 5 years

SELECT
	*
FROM netflix
WHERE
	TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5  years'

-- Find all the movies/tv shows done by 'Rajiv chilaka'

SELECT * FROM netflix
WHERE director LIKE '%Rajiv Chilaka%'

-- List all the tv shows having more than 5 seasons

SELECT 
	*
FROM netflix
WHERE
	SPLIT_PART(duration, ' ', 1)::numeric > 5
	AND
	type = 'TV Show'

-- Count the number of content items in each genre

SELECT
	UNNEST(STRING_TO_ARRAY(listed_in,',')) as genre,
	COUNT(show_id)
FROM netflix
GROUP BY 1

-- Find each year and average number of content release by India on netflix. Return top 5 year with highestavg content release.

SELECT
	EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD, YYYY')) as year,
	COUNT(*) AS Yearly_content,
	ROUND(COUNT(*)::numeric/(SELECT COUNT(*) FROM netflix WHERE country = 'India')::numeric * 100, 2) as avg_content
FROM netflix
WHERE country = 'India'
GROUP BY 1

-- List all the movies that are documentries

SELECT * FROM netflix
WHERE listed_in ILIKE '%documentaries%'

-- Find all content wothout director

SELECT * FROM netflix
WHERE director is NULL

-- Find how many movies actor named 'Salman Khan' appeared in last 10 years

SELECT * FROM netflix
WHERE
	casts ILIKE '%Salman Khan%'
	AND
	release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10

-- Find the top 10 actors that appeared in most movies produced in india

SELECT 
	UNNEST(STRING_TO_ARRAY(casts, ',')) as actors,
	COUNT(*) AS total_content
	FROM netflix
WHERE country ILIKE '%india%'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10

-- Categorise the content based on the presence of the keyword 'kill' and ' violence' in the decription field. Label content containing these words as 'bad' and all the other as 'good', Count how many items fall into each category.

WITH new_table
AS
(SELECT
*,
	CASE
	WHEN
		description ILIKE '%kill%' OR
		description ILIKE '%violence%' THEN 'Bad_content'
		ELSE 'good_content'
	END category
FROM netflix
)
SELECT 
	category,
	COUNT(*) as total
FROM new_table
GROUP BY 1


