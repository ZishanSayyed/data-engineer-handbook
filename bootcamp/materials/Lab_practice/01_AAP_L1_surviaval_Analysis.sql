--DELETE FROM users_growth_accounting

-- retain analysis


-- SELECT 
--      date,
--      COUNT(CASE WHEN daily_active_state IN ('Retained','Resurrected','New') THEN 1 END) as Num_active, 
--      CAST(COUNT(CASE WHEN daily_active_state IN ('Retained','Resurrected','New') THEN 1 END) AS REAL)/COUNT(1) as ptc_active, 

--      COUNT(1) 
-- FROM users_growth_accounting
-- WHERE first_active_date=DATE('2023-01-01')
-- GROUP BY date
-- ORDER BY date ASC

-- survival analysis

SELECT
    --EXTRACT(dow FROM first_active_date) as dow,
     date - first_active_date AS days_since_first_active,
     COUNT(CASE WHEN daily_active_state IN ('Retained','Resurrected','New') THEN 1 END) as Num_active, 
     CAST(COUNT(CASE WHEN daily_active_state IN ('Retained','Resurrected','New') THEN 1 END) AS REAL)/COUNT(1) as ptc_active, 

     COUNT(1) 
FROM users_growth_accounting
--WHERE first_active_date=DATE('2023-01-01')
GROUP BY date - first_active_date 
ORDER BY date - first_active_date  ASC