use operations;

SELECT * FROM operations.project1;

-- jobs per hr per day
select count(distinct job_id)/(30*24) as jobs_phr_pday
from project1
where ds >= '2020-11-01' and ds <= '2020-11-30';

-- Throughput
WITH q2 AS (
SELECT ds, COUNT(distinct event) as total_events
FROM project1
where ds >= '2020-11-01' and ds <= '2020-11-30'
GROUP BY ds
ORDER BY ds
)
SELECT ds, total_events,
AVG(total_events) OVER (ORDER BY ds ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS 7day_rolling_avg
FROM q2;

-- Percentage share of each language
SELECT language, count(language) as total_language,
count(*)*100.0/sum(count(*)) OVER() AS percentage
FROM project1
where ds >= '2020-11-01' and ds <= '2020-11-30'
GROUP BY language
ORDER BY language;

-- Duplicate rows
SELECT ds, job_id, actor_id, event, language, time_spent, org, count(*) as Duplicates
From project1
GROUP BY job_id, actor_id, event, language, time_spent, org
HAVING count(*) > 1;
