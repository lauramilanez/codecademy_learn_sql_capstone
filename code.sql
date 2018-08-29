---------- SECTION 1) GETTING FAMILIAR WITH WARBY PARKER ----------

-- THE SURVEY TABLE
-- What columns does the table have?
SELECT *
FROM survey
LIMIT 10;
-- 1986 rows

-- How many possible answers are there per question?
-- This assumes all answers were selected at least once
SELECT
question,
COUNT(DISTINCT response) AS 'unique responses'
FROM survey
GROUP BY 1 ORDER BY 1;

-- Example responses (getting insight into the questions)
-- subbed in 1, 2, 4, and 5
SELECT
DISTINCT response
FROM survey
WHERE question LIKE '3%';

-- Number of users that took the survey
SELECT COUNT(DISTINCT user_id)
FROM survey;

-- Average number of answers per user, given 1986 rows on table
SELECT 1986.0/500;

-- THE QUIZ TABLE
-- What columns does the table have?
SELECT *
FROM quiz
LIMIT 5;
-- 1000 rows

-- Looking at the split between style preferences to infer gender distribution of respondents
SELECT
style,
COUNT (DISTINCT user_id) as 'number of unique users'
FROM quiz
GROUP BY 1 ORDER BY 1;

-- THE HOME TRY-ON TABLE
-- What columns does the table have?
SELECT *
FROM home_try_on
LIMIT 5;
-- 750 rows

--Are entries on the table unique users?
SELECT COUNT(DISTINCT user_id)
FROM home_try_on;

--Confirming the split between variants
SELECT 
number_of_pairs,
COUNT(*)
FROM home_try_on
GROUP BY 1;

-- THE PURCHASE TABLE
-- What columns does the table have?
SELECT *
FROM purchase
LIMIT 5;
-- 495 rows

-- Number of products available
SELECT COUNT(DISTINCT product_id)
FROM purchase;

-- Did unique users purchase more than once?
SELECT COUNT(DISTINCT user_id)
FROM purchase;

-- Total Revenue
SELECT
1.0*SUM(price) AS 'total revenue'
FROM purchase;

-- Revenue Split by Gender
SELECT 
style,
COUNT(*) AS 'total purchases',
1.0*SUM(price) AS 'total revenue'
FROM purchase
GROUP BY 1 ORDER BY 1;

-- Split by Model Name:
SELECT 
model_name,
COUNT(*) AS 'total purchases',
1.0*SUM(price) AS 'total revenue',
price
FROM purchase
GROUP BY 1 ORDER BY 1;

---------- SECTION 2) USER PREFERENCES ----------
-- by color
SELECT 
color,
COUNT(*) AS 'total selection'
FROM quiz
GROUP BY 1 ORDER BY 1;
-- by style
SELECT 
style,
COUNT(*) AS 'total selection'
FROM quiz
GROUP BY 1 ORDER BY 1;
-- by fit
SELECT 
fit,
COUNT(*) AS 'total selection'
FROM quiz
GROUP BY 1 ORDER BY 1;
-- by shape
SELECT 
shape,
COUNT(*) AS 'total selection'
FROM quiz
GROUP BY 1 ORDER BY 1;

-- BY GENDER THEN BY:
-- by shape
SELECT 
fit,
COUNT(*) AS 'total selection'
FROM quiz
WHERE style LIKE 'Women%'
GROUP BY 1 ORDER BY 1;

SELECT 
fit,
COUNT(*) AS 'total selection'
FROM quiz
WHERE style LIKE 'Men%'
GROUP BY 1 ORDER BY 1;

-- by color
SELECT 
color,
COUNT(*) AS 'total selection'
FROM quiz
WHERE style LIKE 'Women%'
GROUP BY 1 ORDER BY 1;

SELECT 
color,
COUNT(*) AS 'total selection'
FROM quiz
WHERE style LIKE 'Men%'
GROUP BY 1 ORDER BY 1;

---------- SECTION 3) ANALYZING THE QUIZ FUNNEL ----------

-- What is the number of responses for each question?
SELECT question,
   COUNT(DISTINCT user_id) AS 'number of responses'
FROM survey
GROUP BY 1 ORDER BY 1;

---------- SECTION 4) ANALYZING THE HOME TRY-ON FUNNEL ----------

-- New funnel table
-- Creating temporary table combining all three tables from the Home Try-On Funnel
WITH funnel AS
(
  SELECT DISTINCT q.user_id,
  		ht.user_id IS NOT NULL AS 'is_home_try_on',
			ht.number_of_pairs,
  		p.user_id IS NOT NULL AS 'is_purchase'
  FROM quiz AS 'q'
-- Left joining the two additional tables on user_id
  LEFT JOIN home_try_on AS 'ht'
    	ON ht.user_id = q.user_id
  LEFT JOIN purchase AS 'p'
    	ON p.user_id = ht.user_id
)
-- Calculating A/B testing metrics from aggregate table above
SELECT
-- Number of Pairs
		number_of_pairs,
-- Total quiz takers
		COUNT(*) AS 'total quiz user',
-- Total home try-ons
		SUM(is_home_try_on) AS 'total try ons',
-- Total final purchases
		SUM(is_purchase) AS 'total final purchases',
-- Conversion of home try-on to final purchase
    1.0 * SUM(is_purchase) / SUM(is_home_try_on) AS '% home try ons to final purchase'
FROM funnel
GROUP BY 1
ORDER BY 1;

-- New funnel table
-- Creating temporary table combining all three tables from the Home Try-On Funnel
WITH funnel AS
(
  SELECT DISTINCT q.user_id,
  		ht.user_id IS NOT NULL AS 'is_home_try_on',
			ht.number_of_pairs,
  		p.user_id IS NOT NULL AS 'is_purchase'
  FROM quiz AS 'q'
-- Left joining the two additional tables on user_id
  LEFT JOIN home_try_on AS 'ht'
    	ON ht.user_id = q.user_id
  LEFT JOIN purchase AS 'p'
    	ON p.user_id = ht.user_id
)
-- Calculating funnel metrics from aggregate table above
SELECT
-- Total quiz takers
		COUNT(*) AS 'total quiz user',
-- Total home try-ons
		SUM(is_home_try_on) AS 'total try ons',
-- Total final purchases
		SUM(is_purchase) AS 'total final purchases',
-- Conversion of quiz to home try-on
    1.0 * SUM(is_home_try_on) / COUNT(user_id) AS '% quiz to home try ons',
-- Conversion of home try-on to final purchase
    1.0 * SUM(is_purchase) / SUM(is_home_try_on) AS '% home try ons to final purchase'
FROM funnel;

