--we have user cumulative data 

--SELECT DISTINCT(DATE(event_time)) FROM events ORDER BY DATE(event_time) DESC

-- trying to convert users daily activity into bits 
WITH users AS (

    SELECT * FROM user_cumulative
    WHERE date=DATE('2023-01-31')
),

--- dates for current month in series 
dates AS (

    SELECT * 
          FROM generate_series(
           DATE '2023-01-01', 
           DATE '2023-01-31', 
           INTERVAL '1 day'
                    ) AS date_series

),

--- joining user with the dates table 
place_holder_int AS (

SELECT 
     CASE 
        WHEN 
          -- comparing dates_active with date_series if its >
          dates_active::timestamp[] @> ARRAY[date_series::timestamp]

        -- then subtract the date and convert the number into power of 32 
        THEN POWER(2,32 -(date- DATE(date_series)))
        -- else put it as 0
        ELSE 0 END AS place_holder_int_value,
     
     *
FROM user_cumulative CROSS JOIN dates
--WHERE user_id='17358702759623100000'
)

SELECT user_id,
      --dates_active,
      --SUM(place_holder_int_value),

      -- sumining up the place_holder_int_value and converting it into 32 bits 
      CAST(CAST(SUM(place_holder_int_value) AS BIGINT) AS BIT(32))
      As active_days,
      
      -- to find monthly active users 
      BIT_COUNT(CAST(CAST(SUM(place_holder_int_value) 
      AS BIGINT) AS BIT(32))) > 0 AS dim_is_monthly_active,
      
      /* finding weekly active user by comparing  
      11111110000000000000000000000000 & place_holder_int_value if true  */
      BIT_COUNT(CAST('11111110000000000000000000000000' AS BIT(32)) 
      & (CAST(CAST(SUM(place_holder_int_value) 
      AS BIGINT) AS BIT(32)))) > 0 AS dim_is_weekly_active,
      
      /* finding daily active user by comparing  
      1000000000000000000000000000000 & place_holder_int_value if true  */
      BIT_COUNT(CAST('10000000000000000000000000000000' AS BIT(32)) 
      & (CAST(CAST(SUM(place_holder_int_value) 
      AS BIGINT) AS BIT(32)))) > 0 AS dim_is_daily_active


FROM place_holder_int
GROUP BY user_id




