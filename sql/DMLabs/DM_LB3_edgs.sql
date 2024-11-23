-- checking for duplicates 
-- SELECT player_id,game_id,count(1) FROM game_details GROUP BY 1,2

--DELETE FROM edges WHERE TRUE

WITH game_dup AS ( 
    SELECT *,
    ROW_NUMBER() OVER(PARTITION BY player_id,game_id) as row_num
     FROM game_details)

     

INSERT INTO edges
SELECT 
      player_id AS subject_identifier,
      'player':: vertex_type AS subject_type,
      game_id AS object_identifier,
      'game' :: vertex_type AS object_identifier,
      'plays_in' :: edge_type AS edge_type,
      json_build_object (
        'start_position', start_position,
        'pts' ,pts,
        'team_id',team_id,
        'team_abbreviation', team_abbreviation
      ) as properties


FROM game_dup WHERE row_num=1
