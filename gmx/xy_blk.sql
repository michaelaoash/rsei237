-- RSEI 2.3.5 - Census 2010 Crosswalk

-- This file reads in the RSEI-Census crosswalk and runs some simple
-- checks of whether parts sum to wholes.


SET SQL_BIG_SELECTS=1 ;
USE rsei235gmx ;
DROP TABLE IF EXISTS xy_blk_2010 ;

CREATE TABLE  `xy_blk_2010`  (
  `gridid` SMALLINT(6) DEFAULT NULL,
  `x` SMALLINT(6) DEFAULT NULL,  
  `y` SMALLINT(6) DEFAULT NULL,
  `blockid00` VARCHAR(15),
  `ur` VARCHAR(1),
  `pct_b_c` FLOAT DEFAULT NULL,
  `pct_c_b` FLOAT DEFAULT NULL,
  `pct_cp_b` FLOAT DEFAULT NULL,
  KEY `xy` (`x`,`y`),
  KEY `blockid00` (`blockid00`) 
) ENGINE=MyISAM DEFAULT CHARSET=latin1 MAX_ROWS=1210000000;  

ALTER TABLE `xy_blk_2010` DISABLE KEYS ;

LOAD DATA LOCAL INFILE 'CensusBlock2010_Alaska_810m.csv'
INTO TABLE xy_blk_2010
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES ;

SHOW WARNINGS ;

LOAD DATA LOCAL INFILE 'CensusBlock2010_Hawaii_810m.csv'
INTO TABLE xy_blk_2010
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES ;

SHOW WARNINGS ;

LOAD DATA LOCAL INFILE 'CensusBlock2010_PuertoRico_810m.csv'
INTO TABLE xy_blk_2010
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES ;

SHOW WARNINGS ;

LOAD DATA LOCAL INFILE 'CensusBlock2010_ConUS_810m.csv'
INTO TABLE xy_blk_2010
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES ;

SHOW WARNINGS ;




ALTER TABLE  `xy_blk_2010` ENABLE KEYS;

SELECT substr(blockid00,1,2) AS state,MIN(all_b_c) AS statemin ,MAX(all_b_c) AS statemax
FROM (SELECT blockid00,SUM(pct_b_c) AS all_b_c FROM xy_blk_2010 GROUP BY blockid00) A 
GROUP BY state ORDER BY statemin;

