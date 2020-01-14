-- SET SQL_BIG_SELECTS=1 ;
-- Note change in blkgrps between Census 2010 and ACS 2011 and later.
use ashm_rsei237gma ;

-- This script aggregates (by area-weighted averaging) RSEI xy data to
-- 2010 Census blkgrps and then merges ACS (20175) blkgrps.

-- RSEI Scores are not preserved because they are hard to interpret in
-- variable-area units (such as Census blkgrps).

DROP TABLE IF EXISTS c_contrib ;
CREATE TABLE c_contrib
SELECT b.grid,b.x,b.y,blkgrp_id AS blkgrp_id_2010,ReleaseNumber,
IFNULL(p_blkgrp_c*ToxConc,0) AS c_contrib_toxconc,
IFNULL(p_blkgrp_c*Conc,0) AS c_contrib_conc
FROM ashm_rsei_cross2016.xy_blkgrps b 
LEFT JOIN cell_2017 c ON b.grid=c.grid AND b.x=c.x AND b.y=c.y ;

CREATE INDEX sct ON c_contrib (blkgrp_id_2010) ;
CREATE INDEX ReleaseNumber ON c_contrib (ReleaseNumber) ;

DROP TABLE IF EXISTS blkgrp_2017_temp ;
CREATE TABLE blkgrp_2017_temp
SELECT blkgrp_id_2010,ReleaseNumber,SUM(c_contrib_toxconc) AS ToxConc2017, SUM(c_contrib_conc) AS Conc2017
FROM c_contrib
GROUP BY blkgrp_id_2010,ReleaseNumber ;

CREATE INDEX sct ON blkgrp_2017_temp (blkgrp_id_2010) ;

DROP TABLE IF EXISTS blkgrp_2017 ;
CREATE TABLE blkgrp_2017
SELECT blkgrp_id_2010,blkgrp_id_2017,ReleaseNumber,ToxConc2017,Conc2017
FROM blkgrp_2017_temp LEFT JOIN ashm_acs20175.acs_blkgrp USING (blkgrp_id_2010) ;

CREATE INDEX sct2010 ON blkgrp_2017 (blkgrp_id_2010) ;
CREATE INDEX sct2017 ON blkgrp_2017 (blkgrp_id_2017) ;
CREATE INDEX ReleaseNumber ON blkgrp_2017 (ReleaseNumber) ;
