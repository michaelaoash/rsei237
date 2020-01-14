-- SET SQL_BIG_SELECTS=1 ;
-- OK to use rsei235gmx Census 2010 xy crosswalk with rsei237gma data
-- Note change in tracts between Census 2010 and ACS 2011 and later.
use ashm_rsei237gma ;

-- This script aggregates (by area-weighted averaging) RSEI xy data to
-- 2010 Census tracts and then merges ACS (20175) tracts.

-- RSEI Scores are not preserved because they are hard to interpret in
-- variable-area units (such as Census tracts).

DROP TABLE IF EXISTS c_contrib ;
CREATE TABLE c_contrib
SELECT b.grid,b.x,b.y,tract_id AS tract_id_2010,ReleaseNumber,
IFNULL(p_tract_c*ToxConc,0) AS c_contrib_toxconc,
IFNULL(p_tract_c*Conc,0) AS c_contrib_conc
FROM ashm_rsei235gmx.xy_tracts b 
LEFT JOIN cell_2017 c ON b.grid=c.grid AND b.x=c.x AND b.y=c.y ;

CREATE INDEX sct ON c_contrib (tract_id_2010) ;
CREATE INDEX ReleaseNumber ON c_contrib (ReleaseNumber) ;

DROP TABLE IF EXISTS tract_2017_temp ;
CREATE TABLE tract_2017_temp
SELECT tract_id_2010,ReleaseNumber,SUM(c_contrib_toxconc) AS ToxConc2017, SUM(c_contrib_conc) AS Conc2017
FROM c_contrib
GROUP BY tract_id_2010,ReleaseNumber ;

CREATE INDEX sct ON tract_2017_temp (tract_id_2010) ;

DROP TABLE IF EXISTS tract_2017 ;
CREATE TABLE tract_2017
SELECT tract_id_2010,tract_id_2017,ReleaseNumber,ToxConc2017,Conc2017
FROM tract_2017_temp LEFT JOIN ashm_acs20175.acs_tracts USING (tract_id_2010) ;

CREATE INDEX sct2010 ON tract_2017 (tract_id_2010) ;
CREATE INDEX sct2017 ON tract_2017 (tract_id_2017) ;
CREATE INDEX ReleaseNumber ON tract_2017 (ReleaseNumber) ;
