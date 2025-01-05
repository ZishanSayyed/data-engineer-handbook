---- AAF Funnel Analysis

--- de-duplicating data 
WITH deduped_events AS (
    SELECT url,host,user_id,event_time
    FROM events 
    GROUP BY 1,2,3,4),


-- cleaning data 
Cleaned_event AS (
    SELECT * ,DATE(event_time) as event_date
    FROM deduped_events
    WHERE user_id IS NOT NULL
    ORDER BY user_id,event_date),

-- insted of using CET we are using self join to determine user journey
self_join AS (
    SELECT
      ce1.user_id,     
      ce1.url ,
      ce2.url as destination_url,
      ce1.event_time,
      ce2.event_time
      --COUNT(DISTINCT CASE WHEN ce2.url='/api/v1/login' THEN ce2.url END) as converted
      

     
    FROM Cleaned_event ce1
    JOIN Cleaned_event ce2
    ON ce1.user_id=ce2.user_id
    -- making sure sigup should be later then landing 
    AND ce1.event_time > ce2.event_time
   --WHERE ce1.url='/signup'
   ),


user_level AS (
    SELECT 
    user_id,
    url,
    COUNT(1) as number_of_hit,
    SUM(DISTINCT CASE WHEN destination_url='/login' THEN 1 ELSE 0 END) as converted
       
FROM self_join
GROUP BY user_id,url
)


--SELECT destination_url,count(1) FROM self_join GROUP BY 1 ORDER BY destination_url DESC

SELECT 
    url,
    SUM(number_of_hit) as hits ,
    SUM(converted) as num_converted,
    SUM(converted)/SUM(number_of_hit) AS ptc_converted
 FROM user_level
 GROUP BY url
 HAVING SUM(number_of_hit) >500


