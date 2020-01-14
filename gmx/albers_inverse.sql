-- Albers Conical Equal-Area
-- Converts northing, easting to latitude, longitude
-- http://mathworld.wolfram.com/AlbersEqual-AreaConicProjection.html
-- John Snyder, Map Projections, A Working Manual, USGS
-- http://pubs.er.usgs.gov/djvu/PP/PP_1395.pdf
-- http://en.wikipedia.org/wiki/North_American_Datum
-- http://en.wikipedia.org/wiki/Geodetic_system

-- NOTE: This only works for Grid 14 (Continental US)

USE rsei230 ;

CREATE TEMPORARY TABLE myfac 
SELECT * FROM facility WHERE GridCode=14 ;
ALTER TABLE myfac 
ADD easting DOUBLE,
ADD northing DOUBLE,
ADD rlon DOUBLE,
ADD rlat DOUBLE,
ADD xcheck DOUBLE,
ADD ycheck DOUBLE,
ADD longcheck DOUBLE,
ADD latcheck DOUBLE,
ADD q DOUBLE,
ADD beta DOUBLE,
ADD theta DOUBLE,
ADD rho DOUBLE,
ADD phi DOUBLE,
ADD lambda DOUBLE ;

-- Ellipsoid from NAD 83 (Specified by Firlie, Abt 12/23/2010)
SET @A = 6378137 ;
SET @FLATTENING = 1/298.257222101 ;
SET @E = SQRT(2*@FLATTENING - POWER(@FLATTENING,2)) ;

SELECT @E ;

-- Needed Albers parameters
SET @SP1R = RADIANS(29.5);
SET @SP2R = RADIANS(45.5);
SET @CLONGR = RADIANS(-96.0);
SET @MLATR = RADIANS(23.0);

SET @M1 = COS(@SP1R) / SQRT(1-POWER(@E*SIN(@SP1R),2) ) ;
SET @M2 = COS(@SP2R) / SQRT(1-POWER(@E*SIN(@SP2R),2) ) ;

SET @Q0 = (1-POWER(@E,2)) * ( SIN(@MLATR)/(1-POWER(@E*SIN(@MLATR),2)) - 1/(2*@E) * LOG((1-@E*SIN(@MLATR)) / (1 + @E*SIN(@MLATR)) ) ) ;

SET @Q1 = (1-POWER(@E,2)) * ( SIN(@SP1R)/(1-POWER(@E*SIN(@SP1R),2)) - 1/(2*@E) * LOG((1-@E*SIN(@SP1R)) / (1 + @E*SIN(@SP1R)) ) ) ;

SET @Q2 = (1-POWER(@E,2)) * ( SIN(@SP2R)/(1-POWER(@E*SIN(@SP2R),2)) - 1/(2*@E) * LOG((1-@E*SIN(@SP2R)) / (1 + @E*SIN(@SP2R)) ) ) ;

SET @N = (POWER(@M1,2) - POWER(@M2,2)) / (@Q2 - @Q1) ;

SET @C = POWER(@M1,2) + @N*@Q1 ;

SET @RHO0 = @A*SQRT(@C - @N*@Q0) / @N ;




UPDATE myfac SET
rlon=RADIANS(longitude),
rlat=RADIANS(latitude),
q = (1-POWER(@E,2)) * ( SIN(rlat)/(1-POWER(@E*SIN(rlat),2)) - 1/(2*@E) * LOG((1-@E*SIN(rlat)) / (1 + @E*SIN(rlat))  ) ) ,
rho = @A*SQRT(@C - @N*q) / @N,
theta = @N * (rlon - @CLONGR),
easting = rho*SIN(theta),
northing = (@RHO0 - rho*COS(theta)),
xcheck = IF(easting>0, FLOOR(easting/810 + 0.5), CEILING(easting/810 - 0.5) ),
ycheck = IF(northing>0, FLOOR(northing/810+0.5), CEILING(northing/810 - 0.5) ) ;

SELECT x-xcheck,y-ycheck,COUNT(*) FROM myfac GROUP BY x-xcheck,y-ycheck ;


UPDATE myfac SET
-- easting = 810*x,
-- northing = 810*y,
rho = sqrt ( POWER(easting,2) + POWER((@RHO0 - northing),2) ),
q = ( @C - POWER(rho,2) * POWER(@N,2) / POWER(@A,2) ) / @N,
theta = ATAN(  easting / (@RHO0 - northing) ),
beta = ASIN( q / (1 - (1 - POWER(@E,2))/(2*@E) * LN( (1-@E)/(1+@E)   )  ) ),
lambda = @CLONGR  + theta / @N,
phi = beta + ( POWER(@E,2) / 3 + 31 * POWER(@E,4) / 180 + 517 * POWER(@E,6) / 5040 )* SIN(2*beta)  + 
    (23* POWER(@E,4) / 360 + 251 * POWER(@E,6) / 3780 ) * SIN(4*beta) + (761 * POWER(@E,6)/45360)*SIN(6*beta),
longcheck=DEGREES(lambda),
latcheck=DEGREES(phi)
;

SELECT ROUND(10000*(longitude-longcheck),0),ROUND(10000*(latitude-latcheck),0),COUNT(*) FROM myfac GROUP BY 1,2 ;

