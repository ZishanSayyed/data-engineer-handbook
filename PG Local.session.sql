SELECT * FROM processed_events_aggregated







-- SELECT * 
-- FROM processed_events
-- WHERE geodata::json->>'state' = 'Maharashtra';


-- SELECT distinct(DATE(event_timestamp)),
--       count(1)
--  FROM processed_events
--  GROUP BY distinct(DATE(event_timestamp))

-- DELETE FROM processed_events


-- SELECT geodata::json->>'country' AS COUNTRY,
--        geodata::json->>'state' AS State, 
--        count(1)
-- FROM processed_events
-- GROUP BY geodata::json->>'country',
--          geodata::json->>'state'

-- CREATE TABLE processed_events_aggregated  (
--      event_hour TIMESTAMP(3),
--      host VARCHAR,
--      referrer VARCHAR,
--      num_hits BIGINT)