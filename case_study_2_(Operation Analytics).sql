create database operations;
use operations;
select * from users;
select * from events;
CREATE TABLE events (
user_id VARCHAR(40),
occured_at datetime,
event_type char(100),
event_name char(100),
location varchar(80),
device varchar(80),
user_type varchar(20)
);

use operations;


-- WEEKY USER ENGAGEMENT
SELECT EXTRACT(WEEK FROM occured_at) AS week, COUNT(DISTINCT user_id) as user_count
FROM events
WHERE event_type = "engagement"
GROUP BY week
ORDER BY week;

-- user growth rate (89 rows returned)
WITH user_growth AS (
SELECT extract(year from created_at) as year,
extract(week from created_at) as week_num,
count(*) as user_count
FROM users
where state = 'active'
group by year, week_num
order by year, week_num
)
Select year, week_num, user_count, SUM(user_count) over (ORDER BY year, week_num) AS growth
from user_growth;


-- weekly retention
Select extract(week from occured_at) as week_num, count(case when e.event_type = 'engagement' then e.user_id else NULL end) as engagement,
count(case when e.event_type = 'signup_flow' then e.user_id else null end) as signup
from events as e
group by week_num
order by week_num;

-- Week 17 Retention
with cte1 as (
select distinct user_id, extract(week from occured_at) as signup_week
from events
where event_type = 'signup_flow' and event_name = 'complete_signup'
and extract(week from occured_at) = 17
)
, cte2 as (
select distinct user_id, extract(week from occured_at) as engagement_week
from events
where event_type = 'engagement')
select count(user_id) as total_engaged_users,
sum(case when retention_week > 0 then 1 else 0 end) as retained_users
from (
select cte1.user_id, cte1.signup_week, 
cte2.engagement_week, cte2.engagement_week - cte1.signup_week as retention_week
from cte1 left join cte2
on cte1.user_id = cte2.user_id
order by cte1.user_id) as string;


-- weekly engagement per device (retured 493 rows)
select device, extract(year from occured_at) as year, extract(week from occured_at) as week_number, count(user_id) as num_users
from events
group by device, year, week_number
order by num_users desc;


select * from email_events;
-- Email Engagement
select count(action) as acton_num, extract(month from occurred_at) as month, action
from email_events
group by action, month
order by action, month;