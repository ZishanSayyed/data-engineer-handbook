-- Grouping In AAP --


WITH events_augmented AS (
    SELECT COALESCE(d.os_type, 'unknown')      AS os_type,
           COALESCE(d.device_type, 'unknown')  AS device_type,
           COALESCE(d.browser_type, 'unknown') AS browser_type,
           url,
           user_id
    FROM events e
             JOIN devices d on e.device_id = d.device_id
)

--- Normal Grouping Method
-- SELECT 
--    os_type,
--    device_type,
--    browser_type,
--    COUNT(1)
-- FROM events_augmented
-- GROUP BY 1,2,3


--- Grouping Sets --

-- You will get NULL due to grouping Sets --

-- SELECT 
-- --    os_type,
-- --    device_type,
-- --    browser_type,

--    -- adding column to identify which column is present in grouping 
--    GROUPING(os_type) as os_grouped,
--    GROUPING(device_type) as device_grouped,
--    GROUPING(browser_type) as browser_grouped,

--    CASE
--            WHEN GROUPING(os_type) = 0
--                AND GROUPING(device_type) = 0
--                AND GROUPING(browser_type) = 0
--                THEN 'os_type__device_type__browser'
--            WHEN GROUPING(browser_type) = 0 THEN 'browser_type'
--            WHEN GROUPING(device_type) = 0 THEN 'device_type'
--            WHEN GROUPING(os_type) = 0 THEN 'os_type'
--        END as aggregation_level,

   
--    -- to avoid null due to grouping Sets --
--    COALESCE(os_type,'(OverALL)') as os_type,
--    COALESCE(device_type,'(OverALL)') as device_type,
--    COALESCE(browser_type,'(OverALL)') as browser_type,
   
--    COUNT(1) as num_hits
-- FROM events_augmented
-- GROUP BY GROUPING Sets (
--     (browser_type,os_type,device_type),
--     (browser_type),
--     (os_type),
--     (device_type)
-- )
-- ORDER BY COUNT(1) DESC



--- Grouping CUBE

SELECT 
   CASE
           WHEN GROUPING(os_type) = 0
               AND GROUPING(device_type) = 0
               AND GROUPING(browser_type) = 0
               THEN 'os_type__device_type__browser'
           WHEN GROUPING(browser_type) = 0 THEN 'browser_type'
           WHEN GROUPING(device_type) = 0 THEN 'device_type'
           WHEN GROUPING(os_type) = 0 THEN 'os_type'
       END as aggregation_level,  
 
   COALESCE(os_type,'(OverALL)') as os_type,
   COALESCE(device_type,'(OverALL)') as device_type,
   COALESCE(browser_type,'(OverALL)') as browser_type,
   
   COUNT(1) as num_hits
FROM events_augmented
GROUP BY CUBE (
    (browser_type,os_type,device_type)
    -- (browser_type),
    -- (os_type),
    -- (device_type)
)
ORDER BY COUNT(1) DESC



