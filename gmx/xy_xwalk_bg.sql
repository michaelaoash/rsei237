SET SQL_BIG_SELECTS=1 ;
SET SQL_SAFE_UPDATES=0;

-- This script connects tracts to blocks (using Census geography
-- files) and then, via the Abt/RSEI block-cell connection, tracts to
-- cells.

-- The resulting cell xy_tracts is "fragmented" in that every
-- tract-cell intersection, including report of the percent of the
-- tract from the cell and percent of the cell from the tract

USE ashm_rsei_cross2016 ;

DROP TABLE IF EXISTS blocks_w_blkgrps ;
CREATE TABLE blocks_w_blkgrps
SELECT blkgrp_id,block_id,arealand+areawatr AS area_block,arealand
FROM ashm_census2010.census2010_geog
WHERE sumlev="101" ;

CREATE INDEX blkgrp_id ON blocks_w_blkgrps (blkgrp_id) ;

DROP TABLE IF EXISTS blkgrps ;
CREATE TABLE blkgrps
SELECT stusab,fips,blkgrp_id,arealand+areawatr AS area_blkgrp,arealand,intptlat,intptlon,x AS x_blkgrp,y AS y_blkgrp
FROM ashm_census2010.census2010_geog
WHERE sumlev="140" ;

CREATE UNIQUE INDEX blkgrp_id ON blkgrps (blkgrp_id) ;

DROP TABLE IF EXISTS blocks_blkgrps ;
CREATE TABLE blocks_blkgrps 
SELECT stusab,fips,blkgrp_id,block_id,area_block,area_blkgrp,area_block/area_blkgrp,b.arealand/t.arealand AS p_blkgrp_blk,intptlat,intptlon,x_blkgrp,y_blkgrp
FROM blocks_w_blkgrps b LEFT JOIN blkgrps t USING (blkgrp_id) ;

UPDATE blocks_blkgrps
SET p_blkgrp_blk = 0 
WHERE p_blkgrp_blk IS NULL ;

CREATE UNIQUE INDEX block_id ON blocks_blkgrps (block_id) ;

DROP TABLE IF EXISTS xy_blocks_blkgrps ;
CREATE TABLE xy_blocks_blkgrps 
SELECT c.*,b.*,p_blkgrp_blk * pct_b_c AS p_blkgrp_c
FROM xy_blk_2010 c LEFT JOIN blocks_blkgrps b ON block_id=blockid00 ;

DROP TABLE IF EXISTS xy_blkgrps ;
CREATE TABLE xy_blkgrps
SELECT gridid AS grid,x,y,blkgrp_id, SUM(p_blkgrp_c) AS p_blkgrp_c, SUM(pct_c_b) AS p_c_blkgrp 
FROM xy_blocks_blkgrps
GROUP BY grid,x,y,blkgrp_id ;

CREATE INDEX xy ON xy_blkgrps (grid,x,y) ;
CREATE INDEX sct ON xy_blkgrps (blkgrp_id) ;

