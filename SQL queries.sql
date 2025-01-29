##1st question
SELECT DISTINCT post_type from fact_content;


## 2nd question
SELECT 
    post_type,
    (SELECT MAX(impressions) FROM fact_content WHERE post_type = fc.post_type) AS highest_recorded_impressions,
    (SELECT MIN(impressions) FROM fact_content WHERE post_type = fc.post_type) AS lowest_recorded_impressions
FROM fact_content fc
GROUP BY post_type;

## 3rd question
SELECT fact.*
FROM fact_content AS fact
JOIN dim_dates AS dates
  ON fact.date = dates.date
WHERE (dates.month_name = 'March' OR dates.month_name = 'April') 
  AND dates.weekday_or_weekend = 'weekend';
  
##4th question
select monthname(date) as month_name,
	sum(profile_visits) as total_profile_visits,
	sum(new_followers) as total_new_followers
from fact_account
group by month_name;

##5th question
WITH LikesByCategory AS (
    SELECT post_category,
           SUM(likes) AS total_likes
    FROM fact_content
    WHERE MONTHNAME(date) = 'July'
    GROUP BY post_category
)
SELECT *
FROM LikesByCategory
ORDER BY total_likes DESC;

#6th question
SELECT 
    MONTHNAME(date) AS month_name,
    GROUP_CONCAT(DISTINCT post_category SEPARATOR ', ') AS post_category_names,
    COUNT(DISTINCT post_category) AS post_category_count
FROM fact_content
GROUP BY MONTH(date), MONTHNAME(date)
ORDER BY MONTH(date);

##7th question
SELECT
    post_type,
    SUM(reach) AS total_reach,
    ROUND((SUM(reach) * 100.0) / SUM(SUM(reach)) OVER (), 2) AS reach_percentage
FROM fact_content
GROUP BY post_type
ORDER BY reach_percentage DESC;


## 8th question
SELECT 
    post_category,
    CASE 
        WHEN MONTH(date) BETWEEN 1 AND 3 THEN 'Q1'
        WHEN MONTH(date) BETWEEN 4 AND 6 THEN 'Q2'
        WHEN MONTH(date) BETWEEN 7 AND 9 THEN 'Q3'
        WHEN MONTH(date) BETWEEN 10 AND 12 THEN 'Q4'
    END AS quarter,
    SUM(comments) AS total_comments,
    SUM(saves) AS total_saves
FROM fact_content
GROUP BY post_category, 
         CASE 
             WHEN MONTH(date) BETWEEN 1 AND 3 THEN 'Q1'
             WHEN MONTH(date) BETWEEN 4 AND 6 THEN 'Q2'
             WHEN MONTH(date) BETWEEN 7 AND 9 THEN 'Q3'
             WHEN MONTH(date) BETWEEN 10 AND 12 THEN 'Q4'
         END;


##9th question
SELECT 
    MONTH(date) AS month,
    date,
    new_followers
FROM (
    SELECT 
        MONTH(date) AS month,
        date,
        new_followers,
        ROW_NUMBER() OVER (PARTITION BY MONTH(date) ORDER BY new_followers DESC) AS row_num
    FROM fact_account
) AS RankedData
WHERE row_num <= 3
ORDER BY month, row_num;

##10 question
CREATE DEFINER=`root`@`localhost` PROCEDURE `GetSharesByPostType`(IN week_no varchar(255))
BEGIN
    SELECT post_type, 
           SUM(shares) AS total_shares
    FROM fact_content fact
    JOIN dim_dates date using(date)
    WHERE date.week_no = week_no
    GROUP BY post_type, week_no
    ORDER BY total_shares DESC;
END
