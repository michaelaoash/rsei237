SET SQL_BIG_SELECTS=1 ;
SET SQL_SAFE_UPDATES=0;

-- This script connects tracts to blocks (using Census geography
-- files) and then, via the Abt/RSEI block-cell connection, tracts to
-- cells.

-- The resulting cell xy_tracts is "fragmented" in that every
-- tract-cell intersection, including report of the percent of the
-- tract from the cell and percent of the cell from the tract

USE acs20155 ;

DROP TABLE IF EXISTS blocks ;
CREATE TABLE blocks
ENGINE=MyISAM
SELECT tract_id,block_id,arealand+areawatr AS area_block,arealand
FROM census2010_geog
WHERE sumlev="101" ;

CREATE INDEX tract_id ON blocks (tract_id) ;

DROP TABLE IF EXISTS tracts ;
CREATE TABLE tracts
ENGINE=MyISAM
SELECT stusab,fips,tract_id,arealand+areawatr AS area_tract,arealand,intptlat,intptlon,x AS x_tract,y AS y_tract
FROM census2010_geog
WHERE sumlev="140" ;

CREATE UNIQUE INDEX tract_id ON tracts (tract_id) ;

DROP TABLE IF EXISTS blocks_tracts ;
CREATE TABLE blocks_tracts 
ENGINE=MyISAM
SELECT stusab,fips,tract_id,block_id,area_block,area_tract,area_block/area_tract,b.arealand/t.arealand AS p_tract_blk,intptlat,intptlon,x_tract,y_tract
FROM blocks b LEFT JOIN tracts t USING (tract_id) ;

UPDATE blocks_tracts
SET p_tract_blk = 0 
WHERE p_tract_blk IS NULL ;

CREATE UNIQUE INDEX block_id ON blocks_tracts (block_id) ;

USE rsei235gmx ;

DROP TABLE IF EXISTS xy_blocks ;
CREATE TABLE xy_blocks 
ENGINE=MyISAM
SELECT c.*,b.*,p_tract_blk * pct_b_c AS p_tract_c
FROM xy_blk_2010 c LEFT JOIN acs20155.blocks_tracts b ON block_id=blockid00 ;

DROP TABLE IF EXISTS xy_tracts ;
CREATE TABLE xy_tracts
ENGINE=MyISAM
SELECT gridid AS grid,x,y,tract_id, SUM(p_tract_c) AS p_tract_c, SUM(pct_c_b) AS p_c_tract 
FROM xy_blocks
GROUP BY grid,x,y,tract_id ;


CREATE INDEX xy ON xy_tracts (grid,x,y) ;
CREATE INDEX sct ON xy_tracts (tract_id) ;


