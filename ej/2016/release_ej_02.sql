USE ashm_rsei237gma ;

DROP TABLE IF EXISTS release_ej_2016 ;
CREATE TABLE release_ej_2016
ENGINE=MyISAM DEFAULT CHARSET=latin1 MAX_ROWS=1210000000
SELECT ReleaseNumber,
COUNT(*) AS cell_count,
SUM(score_1) AS score_1,
SUM(score_2) AS score_2,
SUM(score_whitenh) AS score_whitenh,
SUM(score_black) AS score_black,
SUM(score_hisp) AS score_hisp,
SUM(score_poor) AS score_poor,
SUM(score_near_poor) AS score_near_poor,
SUM(score_non_poor) AS score_non_poor,
SUM(pop) AS pop,
SUM(pop_poor) AS pop_poor,
SUM(pop_near_poor) AS pop_near_poor,
SUM(pop_non_poor) AS pop_non_poor,
SUM(pop_black) AS pop_black,
SUM(pop_hisp) AS pop_hisp,
SUM(pop_whitenh) AS pop_whitenh,
SUM(pop_weight) AS pop_weight,
SUM(pop_weight_implied) AS pop_weight_implied
-- SUM(pop_weight_poor) AS pop_weight_poor,
-- SUM(pop_weight_near_poor) AS pop_weight_near_poor,
-- SUM(pop_weight_non_poor) AS pop_weight_non_poor,
-- SUM(pop_weight_black) AS pop_weight_black,
-- SUM(pop_weight_hisp) AS pop_weight_hisp,
-- SUM(pop_weight_whitenh) AS pop_weight_whitenh
FROM ashm_rsei237gma.release_ej_2016_cell
GROUP BY ReleaseNumber ;

CREATE INDEX ReleaseNumber ON release_ej_2016 (ReleaseNumber) ;


