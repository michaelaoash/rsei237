-- Load RSEI 2.3.7 Air Microdata 2016
SET sql_safe_updates=0;

USE ashm_rsei237gma ;

DROP TABLE IF EXISTS cell_2016 ;  

CREATE TABLE  `cell_2016` (
  `grid` TINYINT DEFAULT NULL,
  `x` SMALLINT(6) DEFAULT NULL,  
  `y` SMALLINT(6) DEFAULT NULL,
  `ReleaseNumber` INT(12) DEFAULT NULL,
  `ChemicalNumber` SMALLINT(6) DEFAULT NULL,
  `FacilityNumber` INT(11) DEFAULT NULL,
  `Media` SMALLINT(4) DEFAULT NULL,
  `Conc` DOUBLE DEFAULT NULL,
  `ToxConc` DOUBLE DEFAULT NULL,
  `Score` DOUBLE DEFAULT NULL,
  `ScoreCancer` DOUBLE DEFAULT NULL,
  `ScoreNonCancer` DOUBLE DEFAULT NULL,
  `Pop` DOUBLE DEFAULT NULL,  
  KEY `XY` (`grid`,`X`,`Y`),
  KEY `ReleaseNumber` (`ReleaseNumber`)
) DEFAULT CHARSET=latin1 MAX_ROWS=1210000000;

LOAD DATA LOCAL INFILE 'micro2017_2016.csv'
INTO TABLE cell_2016
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\r\n';

SHOW WARNINGS ;
