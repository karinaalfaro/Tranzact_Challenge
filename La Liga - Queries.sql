--PROCEDURE OF GENERAL TABLE (IMAGE)
CREATE OR REPLACE PROCEDURE "RAPPIBANK_PE"."PE_WRITABLE"."LA_LIGA_GENERAL_TABLE"(SEASON TEXT)
RETURNS TABLE()
LANGUAGE SQL
AS 
$$
DECLARE
RES RESULTSET DEFAULT (
WITH CALCULOS AS (
    SELECT *
        ,TRIM(REGEXP_SUBSTR(TEAM1, '^[^(]+')) AS NAME_TEAM1
        ,TRIM(REGEXP_SUBSTR(TEAM2, '^[^(]+')) AS NAME_TEAM2
        ,REGEXP_REPLACE(TEAM1, '[^0-9]', '')::INT AS N_PLAY_TEAM1
        ,REGEXP_REPLACE(TEAM2, '[^0-9]', '')::INT AS N_PLAY_TEAM2
        ,LEFT(FT, CHARINDEX('-', FT) - 1)::INT AS SCORE_TEAM1
        ,RIGHT(FT, LEN(FT) - CHARINDEX('-', FT))::INT  AS SCORE_TEAM2   
        ,CASE 
            WHEN SCORE_TEAM1 = SCORE_TEAM2 THEN 'DRAW'
            WHEN SCORE_TEAM1 > SCORE_TEAM2 THEN 'TEAM1'
            ELSE 'TEAM2'
         END        
         AS WINNER
    FROM RAPPI.PE_WRITABLE.RPP_PE_BI_LIGA_TBL    
    WHERE SEASON = :SEASON
)
,BASE AS (
    --TEAM1
    SELECT NAME_TEAM1 AS NAME_TEAM
        ,COUNT(N_PLAY_TEAM1) AS N_PLAY
        ,SUM(SCORE_TEAM1) AS SCORE_FAVOR
        ,SUM(SCORE_TEAM2) AS SCORE_AGAINST
        ,SUM(
            CASE 
                WHEN WINNER = 'TEAM1' THEN 3
                WHEN WINNER = 'DRAW' THEN 1
                ELSE 0
             END
         )AS POINTS    
        ,SUM(IFF(WINNER = 'TEAM1', 1, 0)) AS WINS
        ,SUM(IFF(WINNER = 'DRAW', 1, 0)) AS DRAWS
        ,SUM(IFF(WINNER = 'TEAM2', 1, 0)) AS LOSES
    FROM CALCULOS
    GROUP BY 1
    
    UNION ALL

    --TEAM2
    SELECT NAME_TEAM2 AS NAME_TEAM
        ,COUNT(N_PLAY_TEAM2) AS N_PLAY
        ,SUM(SCORE_TEAM2) AS SCORE_FAVOR
        ,SUM(SCORE_TEAM1) AS SCORE_AGAINST
        ,SUM(
            CASE 
                WHEN WINNER = 'TEAM2' THEN 3
                WHEN WINNER = 'DRAW' THEN 1
                ELSE 0
             END
         )AS POINTS    
        ,SUM(IFF(WINNER = 'TEAM2', 1, 0)) AS WINS
        ,SUM(IFF(WINNER = 'DRAW', 1, 0)) AS DRAWS
        ,SUM(IFF(WINNER = 'TEAM1', 1, 0)) AS LOSES       
    FROM CALCULOS
    GROUP BY 1
)
SELECT NAME_TEAM AS EQUIPO
    ,SUM(POINTS) AS PUNTOS_TOTALES
    ,SUM(N_PLAY) AS PARTIDOS_JUGADOS
    ,SUM(SCORE_AGAINST) AS GOLES_EN_CONTRA
    ,SUM(DRAWS) AS PARTIDOS_EMPATADOS
    ,SUM(WINS) AS PARTIDOS_GANADOS
    ,SUM(LOSES) AS PARTIDOS_PERDIDOS
    ,SUM(SCORE_FAVOR) AS GOLES_A_FAVOR    
    ,CAST(PARTIDOS_GANADOS*100/PARTIDOS_JUGADOS AS DECIMAL(10,0))AS WIN_RATIO
FROM BASE
GROUP BY 1
ORDER BY 2 DESC
);

BEGIN
    RETURN TABLE(RES);
END

$$;

--EXAMPLE OF EXECUTING PROCEDURE
CALL "RAPPIBANK_PE"."PE_WRITABLE"."LA_LIGA_GENERAL_TABLE"('2009-10');

-- QUERY FOR POWER BI
WITH CALCULOS AS (
    SELECT
        *,
        TRIM(REGEXP_SUBSTR(TEAM1, '^[^(]+')) AS NAME_TEAM1,
        TRIM(REGEXP_SUBSTR(TEAM2, '^[^(]+')) AS NAME_TEAM2,
        REGEXP_REPLACE(TEAM1, '[^0-9]', '' )::INT AS N_PLAY_TEAM1,
        REGEXP_REPLACE(TEAM2, '[^0-9]', '' )::INT AS N_PLAY_TEAM2,
        LEFT(FT, CHARINDEX('-', FT) - 1 )::INT AS SCORE_TEAM1,
        RIGHT(FT, LEN(FT) - CHARINDEX('-', FT))::INT AS SCORE_TEAM2,
        CASE
            WHEN SCORE_TEAM1 = SCORE_TEAM2 THEN 'DRAW'
            WHEN SCORE_TEAM1 > SCORE_TEAM2 THEN 'TEAM1'
            ELSE 'TEAM2'
        END AS WINNER
    FROM RAPPI.PE_WRITABLE.RPP_PE_BI_LIGA_TBL
)
,BASE AS (
    --TEAM1
    SELECT
        SEASON,
        NAME_TEAM1 AS NAME_TEAM,
        N_PLAY_TEAM1 AS N_PLAY,
        SCORE_TEAM1 AS SCORE_FAVOR,
        SCORE_TEAM2 AS SCORE_AGAINST,
        IFF(WINNER = 'TEAM1', 1, 0) AS WINS,
        IFF(WINNER = 'DRAW', 1, 0) AS DRAWS,
        IFF(WINNER = 'TEAM2', 1, 0) AS LOSES,
        WINS * 3 + DRAWS * 1 AS POINTS
    FROM CALCULOS
    UNION ALL
    --TEAM2
    SELECT
        SEASON,
        NAME_TEAM2 AS NAME_TEAM,
        N_PLAY_TEAM2 AS N_PLAY,
        SCORE_TEAM2 AS SCORE_FAVOR,
        SCORE_TEAM1 AS SCORE_AGAINST,
        IFF(WINNER = 'TEAM2', 1, 0) AS WINS,
        IFF(WINNER = 'DRAW', 1, 0) AS DRAWS,
        IFF(WINNER = 'TEAM1', 1, 0) AS LOSES,
        WINS * 3 + DRAWS * 1 AS POINTS
    FROM CALCULOS
)
SELECT *
FROM BASE
;