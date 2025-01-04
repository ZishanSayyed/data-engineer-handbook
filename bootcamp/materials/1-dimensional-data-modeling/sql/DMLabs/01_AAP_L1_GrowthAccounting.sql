--- User Growth Accounting ---
--SELECT min(event_time), max(event_time) FROM events
--creating table 
--  CREATE TABLE users_growth_accounting (
--      user_id TEXT,
--      first_active_date DATE,
--      last_active_date DATE,
--      daily_active_state TEXT,
--      weekly_active_state TEXT,
--      dates_active DATE[],
--      date DATE,
--      PRIMARY KEY (user_id, date)
--  );

INSERT INTO users_growth_accounting

WITH yesterday AS (
    SELECT *
    FROM users_growth_accounting
    WHERE date = DATE('2023-01-08')
),
today AS (
    SELECT user_id,
        DATE_TRUNC('day', event_time::TIMESTAMP) as today_date,
        COUNT(1)
    FROM events
    WHERE DATE_TRUNC('day', event_time::TIMESTAMP) = DATE('2023-01-09')
        AND user_id IS NOT NULL
    GROUP BY user_id,
        DATE_TRUNC('day', event_time::TIMESTAMP)
)
SELECT COALESCE(CAST(t.user_id AS TEXT), y.user_id) AS user_id,
    -- for first and last active date the order of active date in COALESCE is important
    COALESCE(y.first_active_date, t.today_date) AS first_active_date,
    COALESCE(t.today_date, y.first_active_date) AS last_active_date,
    -- Determine the daily active state of the user
    CASE
        -- If the user ID is NULL in the "yesterday" table, this is a new user
        WHEN y.user_id IS NULL THEN 'New'
         -- If the last active date from yesterday equals today minus 1 day, the user is retained (active yesterday and today)
        WHEN y.last_active_date = t.today_date - Interval '1 day' THEN 'Retained'
         -- If the last active date from yesterday is earlier than today minus 1 day, the user has returned after a gap and is resurrected
        WHEN CAST(y.last_active_date AS DATE) < t.today_date - Interval '1 day' THEN 'Resurrected'
         -- If there is no record of today's activity, and the user's last active date equals yesterday's date, they have churned
        WHEN t.today_date IS NULL
        AND CAST(y.last_active_date AS DATE) = y.date THEN 'Churned' 
        -- For all other cases, classify the user as stale (inactive but doesn't meet other conditions)
        ELSE 'Stale'
    END AS daily_active_state,
    
    -- Determine the weekly active state of the user
    CASE
        -- If the user ID is NULL in the "yesterday" table, this is a new user (not active yesterday)
        WHEN y.user_id IS NULL THEN 'New' 
        -- If the last active date from yesterday is earlier than today minus 7 days, the user has returned after being inactive for over a week and is resurrected
        WHEN CAST(y.last_active_date AS DATE) < t.today_date - Interval '7 day' THEN 'Resurrected' 
        -- If there is no record of today's activity, and the user's last active date equals yesterday's date, they have churned
        WHEN t.today_date IS NULL
        AND CAST(y.last_active_date AS DATE) = y.date - Interval '7 day' THEN 'Churned'
         -- If the user's most recent activity (either today or their last active date) is within the past 7 days, they are retained
        WHEN COALESCE(t.today_date, y.last_active_date::DATE) + Interval '7 day' >= y.date THEN 'Retained' 
        -- For all other cases, classify the user as stale (inactive but doesn't meet other conditions)
        ELSE 'Stale'
    END AS weekly_active_state,
    
    COALESCE(y.dates_active, ARRAY []::DATE []) || CASE
        WHEN t.user_id IS NOT NULL THEN ARRAY [t.today_date::DATE]
        ELSE ARRAY []::DATE []
    END AS date_list,
    COALESCE(t.today_date, y.date + Interval '1 day')::DATE AS date
FROM today t
    FULL OUTER JOIN yesterday y ON CAST(t.user_id AS TEXT) = y.user_id;