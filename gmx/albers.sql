-- Albers Conical Equal-Area
-- Converts latitude, longitude to northing, easting
-- http://mathworld.wolfram.com/AlbersEqual-AreaConicProjection.html
-- John Snyder, Map Projections, A Working Manual, USGS
-- http://pubs.er.usgs.gov/djvu/PP/PP_1395.pdf
-- http://en.wikipedia.org/wiki/North_American_Datum
-- http://en.wikipedia.org/wiki/Geodetic_system


USE rsei231 ;

CREATE TEMPORARY TABLE myfac 
SELECT * FROM facility ;
ALTER TABLE myfac 
ADD rlon DOUBLE,
ADD rlat DOUBLE,
ADD easting DOUBLE,
ADD northing DOUBLE,
ADD xcheck DOUBLE,
ADD ycheck DOUBLE,
ADD q DOUBLE,
ADD theta DOUBLE,
ADD rho DOUBLE ;

-- Ellipsoid from NAD 83 (Specified by Firlie, Abt 12/23/2010)
SET @A = 6378137 ;
SET @FLATTENING = 1/298.257222101 ;
SET @E = SQRT(2*@FLATTENING - POWER(@FLATTENING,2)) ;
SELECT @E ;

-- Needed Albers parameters
-- Grid 14 (Continental US)
SET @GRID = 14 ;
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
ycheck = IF(northing>0, FLOOR(northing/810+0.5), CEILING(northing/810 - 0.5) ) 
WHERE gridcode = @grid ;



-- Needed Albers parameters
-- Alaska
SET @GRID = 24 ;
SET @SP1R = RADIANS(55);
SET @SP2R = RADIANS(65);
SET @CLONGR = RADIANS(-154);
SET @MLATR = RADIANS(50);
SET @M1 = COS(@SP1R) / SQRT(1-POWER(@E*SIN(@SP1R),2) ) ;
SET @M2 = COS(@SP2R) / SQRT(1-POWER(@E*SIN(@SP2R),2) ) ;
SET @Q0 = (1-POWER(@E,2)) * ( SIN(@MLATR)/(1-POWER(@E*SIN(@MLATR),2)) - 1/(2*@E) * LOG((1-@E*SIN(@MLATR)) / (1 + @E*SIN(@MLATR)) ) ) ;
SET @Q1 = (1-POWER(@E,2)) * ( SIN(@SP1R)/(1-POWER(@E*SIN(@SP1R),2)) - 1/(2*@E) * LOG((1-@E*SIN(@SP1R)) / (1 + @E*SIN(@SP1R)) ) ) ;
SET @Q2 = (1-POWER(@E,2)) * ( SIN(@SP2R)/(1-POWER(@E*SIN(@SP2R),2)) - 1/(2*@E) * LOG((1-@E*SIN(@SP2R)) / (1 + @E*SIN(@SP2R)) ) ) ;
SET @N = (POWER(@M1,2) - POWER(@M2,2)) / (@Q2 - @Q1) ;
SET @C = POWER(@M1,2) + @N*@Q1 ;
SET @RHO0 = @A*SQRT(@C - @N*@Q0) / @N ;

UPDATE myfac 
SET 
rlon = RADIANS(longitude),
rlat = RADIANS(latitude),
q = (1-POWER(@E,2)) * ( SIN(rlat)/(1-POWER(@E*SIN(rlat),2)) - 1/(2*@E) * LOG((1-@E*SIN(rlat)) / (1 + @E*SIN(rlat))  ) ) ,
rho = @A*SQRT(@C - @N*q) / @N,
theta = @N * (rlon - @CLONGR),
easting = rho*SIN(theta),
northing = (@RHO0 - rho*COS(theta)),
xcheck = IF(easting>0, FLOOR(easting/810 + 0.5), CEILING(easting/810 - 0.5) ),
ycheck = IF(northing>0, FLOOR(northing/810+0.5), CEILING(northing/810 - 0.5) )
WHERE gridcode=@grid ;



-- Needed Albers parameters
-- Hawaii
SET @GRID = 34 ;
SET @SP1R = RADIANS(19.4375);
SET @SP2R = RADIANS(21.2375);
SET @CLONGR = RADIANS(-157.5625);
SET @MLATR = RADIANS(20.5625);
SET @M1 = COS(@SP1R) / SQRT(1-POWER(@E*SIN(@SP1R),2) ) ;
SET @M2 = COS(@SP2R) / SQRT(1-POWER(@E*SIN(@SP2R),2) ) ;
SET @Q0 = (1-POWER(@E,2)) * ( SIN(@MLATR)/(1-POWER(@E*SIN(@MLATR),2)) - 1/(2*@E) * LOG((1-@E*SIN(@MLATR)) / (1 + @E*SIN(@MLATR)) ) ) ;
SET @Q1 = (1-POWER(@E,2)) * ( SIN(@SP1R)/(1-POWER(@E*SIN(@SP1R),2)) - 1/(2*@E) * LOG((1-@E*SIN(@SP1R)) / (1 + @E*SIN(@SP1R)) ) ) ;
SET @Q2 = (1-POWER(@E,2)) * ( SIN(@SP2R)/(1-POWER(@E*SIN(@SP2R),2)) - 1/(2*@E) * LOG((1-@E*SIN(@SP2R)) / (1 + @E*SIN(@SP2R)) ) ) ;
SET @N = (POWER(@M1,2) - POWER(@M2,2)) / (@Q2 - @Q1) ;
SET @C = POWER(@M1,2) + @N*@Q1 ;
SET @RHO0 = @A*SQRT(@C - @N*@Q0) / @N ;

UPDATE myfac 
SET 
rlon = RADIANS(longitude),
rlat = RADIANS(latitude),
q = (1-POWER(@E,2)) * ( SIN(rlat)/(1-POWER(@E*SIN(rlat),2)) - 1/(2*@E) * LOG((1-@E*SIN(rlat)) / (1 + @E*SIN(rlat))  ) ) ,
rho = @A*SQRT(@C - @N*q) / @N,
theta = @N * (rlon - @CLONGR),
easting = rho*SIN(theta),
northing = (@RHO0 - rho*COS(theta)),
xcheck = IF(easting>0, FLOOR(easting/810 + 0.5), CEILING(easting/810 - 0.5) ),
ycheck = IF(northing>0, FLOOR(northing/810+0.5), CEILING(northing/810 - 0.5) )
WHERE gridcode=@grid ;


-- Needed Albers parameters
-- Puerto Rico/Virgin Islands
SET @GRID = 44 ;
SET @SP1R = RADIANS(17.875);
SET @SP2R = RADIANS(18.5);
SET @CLONGR = RADIANS(-66.25);
SET @MLATR = RADIANS(18.0);
SET @M1 = COS(@SP1R) / SQRT(1-POWER(@E*SIN(@SP1R),2) ) ;
SET @M2 = COS(@SP2R) / SQRT(1-POWER(@E*SIN(@SP2R),2) ) ;
SET @Q0 = (1-POWER(@E,2)) * ( SIN(@MLATR)/(1-POWER(@E*SIN(@MLATR),2)) - 1/(2*@E) * LOG((1-@E*SIN(@MLATR)) / (1 + @E*SIN(@MLATR)) ) ) ;
SET @Q1 = (1-POWER(@E,2)) * ( SIN(@SP1R)/(1-POWER(@E*SIN(@SP1R),2)) - 1/(2*@E) * LOG((1-@E*SIN(@SP1R)) / (1 + @E*SIN(@SP1R)) ) ) ;
SET @Q2 = (1-POWER(@E,2)) * ( SIN(@SP2R)/(1-POWER(@E*SIN(@SP2R),2)) - 1/(2*@E) * LOG((1-@E*SIN(@SP2R)) / (1 + @E*SIN(@SP2R)) ) ) ;
SET @N = (POWER(@M1,2) - POWER(@M2,2)) / (@Q2 - @Q1) ;
SET @C = POWER(@M1,2) + @N*@Q1 ;
SET @RHO0 = @A*SQRT(@C - @N*@Q0) / @N ;

UPDATE myfac 
SET 
rlon = RADIANS(longitude),
rlat = RADIANS(latitude),
q = (1-POWER(@E,2)) * ( SIN(rlat)/(1-POWER(@E*SIN(rlat),2)) - 1/(2*@E) * LOG((1-@E*SIN(rlat)) / (1 + @E*SIN(rlat))  ) ) ,
rho = @A*SQRT(@C - @N*q) / @N,
theta = @N * (rlon - @CLONGR),
easting = rho*SIN(theta),
northing = (@RHO0 - rho*COS(theta)),
xcheck = IF(easting>0, FLOOR(easting/810 + 0.5), CEILING(easting/810 - 0.5) ),
ycheck = IF(northing>0, FLOOR(northing/810+0.5), CEILING(northing/810 - 0.5) )
WHERE gridcode=@grid ;



-- Needed Albers parameters
-- Guam/Marianas
SET @GRID = 54 ;
SET @SP1R = RADIANS(12);
SET @SP2R = RADIANS(15);
SET @CLONGR = RADIANS(155);
SET @MLATR = RADIANS(0);
SET @M1 = COS(@SP1R) / SQRT(1-POWER(@E*SIN(@SP1R),2) ) ;
SET @M2 = COS(@SP2R) / SQRT(1-POWER(@E*SIN(@SP2R),2) ) ;
SET @Q0 = (1-POWER(@E,2)) * ( SIN(@MLATR)/(1-POWER(@E*SIN(@MLATR),2)) - 1/(2*@E) * LOG((1-@E*SIN(@MLATR)) / (1 + @E*SIN(@MLATR)) ) ) ;
SET @Q1 = (1-POWER(@E,2)) * ( SIN(@SP1R)/(1-POWER(@E*SIN(@SP1R),2)) - 1/(2*@E) * LOG((1-@E*SIN(@SP1R)) / (1 + @E*SIN(@SP1R)) ) ) ;
SET @Q2 = (1-POWER(@E,2)) * ( SIN(@SP2R)/(1-POWER(@E*SIN(@SP2R),2)) - 1/(2*@E) * LOG((1-@E*SIN(@SP2R)) / (1 + @E*SIN(@SP2R)) ) ) ;
SET @N = (POWER(@M1,2) - POWER(@M2,2)) / (@Q2 - @Q1) ;
SET @C = POWER(@M1,2) + @N*@Q1 ;
SET @RHO0 = @A*SQRT(@C - @N*@Q0) / @N ;

UPDATE myfac 
SET 
rlon = RADIANS(longitude),
rlat = RADIANS(latitude),
q = (1-POWER(@E,2)) * ( SIN(rlat)/(1-POWER(@E*SIN(rlat),2)) - 1/(2*@E) * LOG((1-@E*SIN(rlat)) / (1 + @E*SIN(rlat))  ) ) ,
rho = @A*SQRT(@C - @N*q) / @N,
theta = @N * (rlon - @CLONGR),
easting = rho*SIN(theta),
northing = (@RHO0 - rho*COS(theta)),
xcheck = IF(easting>0, FLOOR(easting/810 + 0.5), CEILING(easting/810 - 0.5) ),
ycheck = IF(northing>0, FLOOR(northing/810+0.5), CEILING(northing/810 - 0.5) )
WHERE gridcode=@grid ;



-- Needed Albers parameters
-- American Samoa
SET @GRID = 64 ;
SET @SP1R = RADIANS(-12);
SET @SP2R = RADIANS(-15);
SET @CLONGR = RADIANS(-170);
SET @MLATR = RADIANS(0);
SET @M1 = COS(@SP1R) / SQRT(1-POWER(@E*SIN(@SP1R),2) ) ;
SET @M2 = COS(@SP2R) / SQRT(1-POWER(@E*SIN(@SP2R),2) ) ;
SET @Q0 = (1-POWER(@E,2)) * ( SIN(@MLATR)/(1-POWER(@E*SIN(@MLATR),2)) - 1/(2*@E) * LOG((1-@E*SIN(@MLATR)) / (1 + @E*SIN(@MLATR)) ) ) ;
SET @Q1 = (1-POWER(@E,2)) * ( SIN(@SP1R)/(1-POWER(@E*SIN(@SP1R),2)) - 1/(2*@E) * LOG((1-@E*SIN(@SP1R)) / (1 + @E*SIN(@SP1R)) ) ) ;
SET @Q2 = (1-POWER(@E,2)) * ( SIN(@SP2R)/(1-POWER(@E*SIN(@SP2R),2)) - 1/(2*@E) * LOG((1-@E*SIN(@SP2R)) / (1 + @E*SIN(@SP2R)) ) ) ;
SET @N = (POWER(@M1,2) - POWER(@M2,2)) / (@Q2 - @Q1) ;
SET @C = POWER(@M1,2) + @N*@Q1 ;
SET @RHO0 = @A*SQRT(@C - @N*@Q0) / @N ;

UPDATE myfac 
SET 
rlon = RADIANS(longitude),
rlat = RADIANS(latitude),
q = (1-POWER(@E,2)) * ( SIN(rlat)/(1-POWER(@E*SIN(rlat),2)) - 1/(2*@E) * LOG((1-@E*SIN(rlat)) / (1 + @E*SIN(rlat))  ) ) ,
rho = @A*SQRT(@C - @N*q) / @N,
theta = @N * (rlon - @CLONGR),
easting = rho*SIN(theta),
northing = (@RHO0 - rho*COS(theta)),
xcheck = IF(easting>0, FLOOR(easting/810 + 0.5), CEILING(easting/810 - 0.5) ),
ycheck = IF(northing>0, FLOOR(northing/810+0.5), CEILING(northing/810 - 0.5) )
WHERE gridcode=@grid ;



SELECT gridcode,x-xcheck,y-ycheck,COUNT(*) FROM myfac GROUP BY x-xcheck,y-ycheck,gridcode ;


-- SELECT state,longitude,latitude,x,x-xcheck,y,y-ycheck,name FROM myfac ;
-- SELECT FLOOR(longitude),x-xcheck,COUNT(*) FROM myfac WHERE x-xcheck !=0 GROUP BY FLOOR(longitude),x-xcheck;
-- SELECT FLOOR(latitude),y-ycheck,COUNT(*) FROM myfac GROUP BY FLOOR(latitude),y-ycheck;

-- Here is the implementation of spherical earth model
-- SET @N = (SIN(@SP1R) + SIN(@SP2R)) / 2;
-- SET @C = POWER(COS(@SP1R),2) + 2.0*@N*SIN(@SP1R) ;
-- SET @RHO0 = SQRT(@C - 2.0*@N*SIN(@MLATR)) / @N ;
-- UPDATE myfac SET
-- theta = @N * (rlon - @CLONGR),
-- rho = SQRT(@C - 2*@N*SIN(rlat)) / @N,
-- easting = @RADIUS*rho*SIN(theta),
-- northing = @RADIUS*(@RHO0 - rho*COS(theta)),
-- xcheck = IF(easting>0, FLOOR(easting/810 + 0.5), CEILING(easting/810 - 0.5) ),
-- ycheck = IF(northing>0, FLOOR(northing/810 + 0.5), CEILING(northing/810 - 0.5) ) ;
-- SELECT x-xcheck,y-ycheck,COUNT(*) FROM myfac GROUP BY x-xcheck,y-ycheck ;


