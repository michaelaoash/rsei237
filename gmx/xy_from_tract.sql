SET SQL_BIG_SELECTS=1 ;
USE ashm_rsei237gmx ;

-- rsei235 geography (2010 Census tracts)
-- ACS 2013-2017 (5-year 2017 or 20175) social-economic-demographic data

-- Get data from the Census on a tract basis and assign it to RSEI x,y
-- cells (for facility-based analysis)

-- The Census tract data have been processed with acs_tracts.sql
-- (creating, inter alia, RSEI-type IEF-based population weights at
-- the tract level. Check both this file and acs_tracts.sql if the IEFs
-- change at EPA/RSEI

DROP TABLE IF EXISTS tract_contrib ;
CREATE TABLE tract_contrib
ENGINE=MyISAM
SELECT 
xwalk.grid AS grid,
xwalk.x AS x,
xwalk.y AS y,
IFNULL(p_tract_c*pop,0) AS pop,			
IFNULL(p_tract_c*pop_black,0) AS pop_black,
IFNULL(p_tract_c*pop_aian,0) AS pop_aian,
IFNULL(p_tract_c*pop_asian,0) AS pop_asian,		
IFNULL(p_tract_c*pop_hisp,0) AS pop_hisp,		
IFNULL(p_tract_c*pop_whitenh,0) AS pop_whitenh,		
IFNULL(p_tract_c*pop_weight,0) AS pop_weight,		
IFNULL(p_tract_c*pop_poor,0) AS pop_poor,		
IFNULL(p_tract_c*pop_near_poor,0) AS pop_near_poor,	
IFNULL(p_tract_c*pop_non_poor,0) AS pop_non_poor,	

IFNULL(p_tract_c*pop_weight_poor,0) AS pop_weight_poor,	
IFNULL(p_tract_c*pop_weight_near_poor,0) AS pop_weight_near_poor,
IFNULL(p_tract_c*pop_weight_non_poor,0) AS pop_weight_non_poor,
IFNULL(p_tract_c*pop_weight_black,0) AS pop_weight_black,
IFNULL(p_tract_c*pop_weight_aian,0) AS pop_weight_aian,
IFNULL(p_tract_c*pop_weight_asian,0) AS pop_weight_asian,	
IFNULL(p_tract_c*pop_weight_hisp,0) AS pop_weight_hisp,
IFNULL(p_tract_c*pop_weight_whitenh,0) AS pop_weight_whitenh,

IFNULL(p_c_tract*(pop_black / nullif(pop,0) ),0) AS black_shr,
IFNULL(p_c_tract*(pop_aian / nullif(pop,0) ),0) AS aian_shr,
IFNULL(p_c_tract*(pop_asian / nullif(pop,0) ),0) AS asian_shr,
IFNULL(p_c_tract*(pop_poor / nullif(pop,0) ),0) AS poor_shr
FROM ashm_rsei235gmx.xy_tracts xwalk LEFT JOIN ashm_acs20175.acs_tracts acs ON xwalk.tract_id = acs.tract_id_2010 ;
CREATE INDEX xy ON tract_contrib (grid,x,y) ;


DROP TABLE IF EXISTS xy_census ;
CREATE TABLE xy_census
(KEY `XY` (`grid`,`X`,`Y`))
ENGINE=MyISAM
SELECT grid,x,y,
SUM(pop) AS pop,
SUM(pop_poor) AS pop_poor,
SUM(pop_near_poor) AS pop_near_poor,
SUM(pop_non_poor) AS pop_non_poor,
SUM(pop_black) AS pop_black,
SUM(pop_aian) AS pop_aian,
SUM(pop_asian) AS pop_asian,
SUM(pop_hisp) AS pop_hisp,
SUM(pop_whitenh) AS pop_whitenh,
SUM(pop_weight) AS pop_weight,
SUM(pop_weight_poor) AS pop_weight_poor,
SUM(pop_weight_near_poor) AS pop_weight_near_poor,
SUM(pop_weight_non_poor) AS pop_weight_non_poor,
SUM(pop_weight_black) AS pop_weight_black,
SUM(pop_weight_aian) AS pop_weight_aian,
SUM(pop_weight_asian) AS pop_weight_asian,
SUM(pop_weight_hisp) AS pop_weight_hisp,
SUM(pop_weight_whitenh) AS pop_weight_whitenh,
SUM(black_shr) AS black_shr,
SUM(poor_shr) AS poor_shr
FROM  tract_contrib
GROUP BY grid,x,y ;

