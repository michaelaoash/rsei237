USE ashm_rsei237gma ;

DROP TABLE IF EXISTS release_ej_2017_cell ;
CREATE TABLE release_ej_2017_cell 
(KEY `release` (`ReleaseNumber`))
ENGINE=MyISAM DEFAULT CHARSET=latin1 MAX_ROWS=1210000000
SELECT ReleaseNumber,score 
AS score_1,
pop_weight*ToxConc AS score_2,
pop_weight_black*ToxConc AS score_black,
pop_weight_hisp*ToxConc AS score_hisp,
pop_weight_whitenh*ToxConc AS score_whitenh,
pop_weight_poor*ToxConc AS score_poor,
pop_weight_near_poor*ToxConc AS score_near_poor,
pop_weight_non_poor*ToxConc AS score_non_poor,
pop_weight,
IF(ToxConc=0,0,score/ToxConc) AS pop_weight_implied,
c.pop AS pop_RSEI,
g.pop AS pop,
pop_poor,
pop_near_poor,
pop_non_poor,
pop_black,
pop_hisp,
pop_whitenh
FROM cell_2017 c
LEFT JOIN ashm_rsei237gmx.xy_census g USING (grid,x,y)
WHERE media != 6 ;

