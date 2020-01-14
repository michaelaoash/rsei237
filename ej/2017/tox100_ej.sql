-- Need to confirm matchXXX.release_cl and rseiYYY.
USE match20171 ;

CREATE TEMPORARY TABLE score_fac
SELECT rpid,final_parent,f.facilityid,FacilityName,f.city,f.state,
COUNT(*) AS Releases,
SUM(score_rev) AS score_rev,
SUM(pounds_rev*(media<3)) AS pounds_air_rev,
SUM(pounds_rev*(media=750 OR media=754)) AS pounds_incin_rev,
SUM(IFNULL(ratio_rev,1)*score_1) AS score_1,
SUM(IFNULL(ratio_rev,1)*score_2) AS score_2,
SUM(IFNULL(ratio_rev,1)*score_whitenh) AS score_whitenh,
SUM(IFNULL(ratio_rev,1)*score_black) AS score_black,
SUM(IFNULL(ratio_rev,1)*score_hisp) AS score_hisp,
-- SUM(IFNULL(ratio_rev,1)*score_asian) AS score_asian,
-- SUM(IFNULL(ratio_rev,1)*score_pacific) AS score_pacific,
-- SUM(IFNULL(ratio_rev,1)*score_indian) AS score_indian,
SUM(IFNULL(ratio_rev,1)*score_poor) AS score_poor,
SUM(IFNULL(ratio_rev,1)*score_near_poor) AS score_near_poor,
ROUND((1 - SUM(Score_whitenh)/SUM(Score_2)),4) AS ratio_nonwhite,
ROUND(SUM(Score_black)/SUM(Score_2),4) AS ratio_black,
ROUND(SUM(Score_hisp)/SUM(Score_2),4) AS ratio_hisp,
-- -- ROUND(SUM(Score_asian + Score_pacific)/SUM(Score_2),4) AS ratio_a_pac,
-- ROUND(SUM(Score_indian)/SUM(Score_2),4) AS ratio_indian,
ROUND(SUM(Score_poor)/SUM(Score_2),4) AS ratio_poor,
ROUND(SUM(Score_near_poor)/SUM(Score_2),4) AS ratio_near_poor,
MIN(split) AS split,
MAX(ISNULL(score_1) AND score_rev>0) AS nogrid
FROM release_cl r LEFT JOIN rsei237gma.release_ej_2017 j USING (ReleaseNumber),
rsei237.Facility f, tri_par_basic t
WHERE f.facilitynumber=r.facilitynumber
AND (media<3 OR media=750 OR media=754)
AND f.facilityid=t.facility_id
AND year=2017
GROUP BY rpid,facilityid ;


CREATE TEMPORARY TABLE parent
SELECT final_parent, rpid,
COUNT(DISTINCT facilityid) AS Facilities,
SUM(Releases) AS Releases,
SUM(split*score_rev) AS score_rev,
SUM(split*pounds_air_rev) AS pounds_air_rev,
SUM(split*pounds_incin_rev) AS pounds_incin_rev,
SUM(split*score_1) AS score_1,
SUM(split*score_2) AS score_2,
SUM(split*score_whitenh) AS score_whitenh,
SUM(split*score_black) AS score_black,
SUM(split*score_hisp) AS score_hisp,
-- SUM(split*score_asian) AS score_asian,
-- SUM(split*score_pacific) AS score_pacific,
-- SUM(split*score_indian) AS score_indian,
SUM(split*score_poor) AS score_poor,
SUM(split*score_near_poor) AS score_near_poor,
MAX(nogrid) AS nogrid
FROM score_fac s
GROUP BY rpid
ORDER BY score_rev DESC, final_parent ;


CREATE TEMPORARY TABLE score_chem_company
SELECT rpid,final_parent,c.casstandard, IF(CASNumber LIKE 'N%',CASNumber,LPAD(CASNumber,9,"0")) AS cas,chemical, split,
COUNT(*) AS Releases,
SUM(split*score_rev) AS score_rev,
SUM(split*pounds_rev*(media<3)) AS pounds_air_rev,
SUM(split*pounds_rev*(media=750 OR media=754)) AS pounds_incin_rev,
SUM(split*IFNULL(ratio_rev,1)*score_1) AS score_1,
SUM(split*IFNULL(ratio_rev,1)*score_2) AS score_2,
SUM(split*IFNULL(ratio_rev,1)*score_whitenh) AS score_whitenh,
SUM(split*IFNULL(ratio_rev,1)*score_black) AS score_black,
SUM(split*IFNULL(ratio_rev,1)*score_hisp) AS score_hisp,
-- SUM(split*IFNULL(ratio_rev,1)*score_asian) AS score_asian,
-- SUM(split*IFNULL(ratio_rev,1)*score_pacific) AS score_pacific,
-- SUM(split*IFNULL(ratio_rev,1)*score_indian) AS score_indian,
SUM(split*IFNULL(ratio_rev,1)*score_poor) AS score_poor,
SUM(split*IFNULL(ratio_rev,1)*score_near_poor) AS score_near_poor,
ROUND((1 - SUM(split*Score_whitenh)/SUM(split*Score_2)),4) AS ratio_nonwhite,
ROUND(SUM(split*Score_black)/SUM(split*Score_2),4) AS ratio_black,
ROUND(SUM(split*Score_hisp)/SUM(split*Score_2),4) AS ratio_hisp,
-- -- ROUND(SUM(split*Score_asian + Score_pacific)/SUM(split*Score_2),4) AS ratio_a_pac,
-- ROUND(SUM(split*Score_indian)/SUM(split*Score_2),4) AS ratio_indian,
ROUND(SUM(split*Score_poor)/SUM(split*Score_2),4) AS ratio_poor,
ROUND(SUM(split*Score_near_poor)/SUM(split*Score_2),4) AS ratio_near_poor,
MAX(ISNULL(score_2) AND score_rev>0) AS nogrid
FROM release_cl r LEFT JOIN rsei237gma.release_ej_2017 j USING (ReleaseNumber),
rsei237.Facility f,rsei237.Chemical c, tri_par_basic t
WHERE c.chemicalnumber=r.chemicalnumber
AND f.facilitynumber=r.facilitynumber
AND (media<3 OR media=750 OR media=754)
AND f.facilityid=t.facility_id
AND year=2017
GROUP BY rpid,cas ;


-- Report Score and EJ by chemical (not by company)
CREATE TEMPORARY TABLE score_chemicals
SELECT c.casstandard, IF(CASNumber LIKE 'N%',CASNumber,LPAD(CASNumber,9,"0")) AS cas,chemical,itw,incineratorDRE,
COUNT(*) AS Releases,
COUNT(DISTINCT facilitynumber) AS Facilities,
SUM(score_rev) AS score_rev,
SUM(pounds_rev*(media<3)) AS pounds_air_rev,
SUM(pounds_rev*(media=750 OR media=754)) AS pounds_incin_rev,
SUM(IFNULL(ratio_rev,1)*score_1) AS score_1,
SUM(IFNULL(ratio_rev,1)*score_2) AS score_2,
SUM(IFNULL(ratio_rev,1)*score_whitenh) AS score_whitenh,
SUM(IFNULL(ratio_rev,1)*score_black) AS score_black,
SUM(IFNULL(ratio_rev,1)*score_hisp) AS score_hisp,
-- SUM(IFNULL(ratio_rev,1)*score_asian) AS score_asian,
-- SUM(IFNULL(ratio_rev,1)*score_pacific) AS score_pacific,
-- SUM(IFNULL(ratio_rev,1)*score_indian) AS score_indian,
SUM(IFNULL(ratio_rev,1)*score_poor) AS score_poor,
SUM(IFNULL(ratio_rev,1)*score_near_poor) AS score_near_poor,
ROUND((1 - SUM(Score_whitenh)/SUM(Score_2)),4) AS ratio_nonwhite,
ROUND(SUM(Score_black)/SUM(Score_2),4) AS ratio_black,
ROUND(SUM(Score_hisp)/SUM(Score_2),4) AS ratio_hisp,
-- -- ROUND(SUM(Score_asian + Score_pacific)/SUM(Score_2),4) AS ratio_a_pac,
-- ROUND(SUM(Score_indian)/SUM(Score_2),4) AS ratio_indian,
ROUND(SUM(Score_poor)/SUM(Score_2),4) AS ratio_poor,
ROUND(SUM(Score_near_poor)/SUM(Score_2),4) AS ratio_near_poor,
MAX(ISNULL(score_2) AND score_rev>0) AS nogrid
FROM release_cl r LEFT JOIN rsei237gma.release_ej_2017 j USING (ReleaseNumber),
rsei237.Chemical c
WHERE c.chemicalnumber=r.chemicalnumber
AND (media<3 OR media=750 OR media=754)
AND year=2017
GROUP BY cas ;

-- ej_version_chemical.csv  complete, ranked list of chemicals ordered by descending score
SELECT 'begin ej_237_2017_chemical' AS ``;
SELECT chemical,itw,incineratordre,facilities,score_rev,pounds_air_rev,pounds_incin_rev,
ratio_nonwhite,ratio_black,ratio_hisp,ratio_poor,ratio_near_poor
-- ratio_a_pac,ratio_indian,
FROM score_chemicals 
-- WHERE ratio_nonwhite>40 OR ratio_poor>15
ORDER BY score_rev DESC,ratio_nonwhite DESC ;
SELECT 'end ej_237_2017_chemical' AS `` ;



-- Report Score and EJ by sector (not by company)
-- Create two digit sic table (NAICS is not yet fully implemented in TRI)
-- CREATE TEMPORARY TABLE twodigitsic 
-- SELECT substr(sic,1,2) AS SICCode2Digit,sic,sic_tr FROM alldb.all_sic_cd WHERE substr(sic,3,2)="00" ;
-- This is now a permanent table in alldb

CREATE TEMPORARY TABLE score_sectors
SELECT NAICSCode3Digit,
COUNT(*) AS Releases,
COUNT(DISTINCT r.facilitynumber) AS Facilities,
SUM(score_rev) AS score_rev,
SUM(pounds_rev*(media<3)) AS pounds_air_rev,
SUM(pounds_rev*(media=750 OR media=754)) AS pounds_incin_rev,
SUM(IFNULL(ratio_rev,1)*score_1) AS score_1,
SUM(IFNULL(ratio_rev,1)*score_2) AS score_2,
SUM(IFNULL(ratio_rev,1)*score_whitenh) AS score_whitenh,
SUM(IFNULL(ratio_rev,1)*score_black) AS score_black,
SUM(IFNULL(ratio_rev,1)*score_hisp) AS score_hisp,
-- SUM(IFNULL(ratio_rev,1)*score_asian) AS score_asian,
-- SUM(IFNULL(ratio_rev,1)*score_pacific) AS score_pacific,
-- SUM(IFNULL(ratio_rev,1)*score_indian) AS score_indian,
SUM(IFNULL(ratio_rev,1)*score_poor) AS score_poor,
SUM(IFNULL(ratio_rev,1)*score_near_poor) AS score_near_poor,
ROUND((1 - SUM(Score_whitenh)/SUM(Score_2)),4) AS ratio_nonwhite,
ROUND(SUM(Score_black)/SUM(Score_2),4) AS ratio_black,
ROUND(SUM(Score_hisp)/SUM(Score_2),4) AS ratio_hisp,
-- -- ROUND(SUM(Score_asian + Score_pacific)/SUM(Score_2),4) AS ratio_a_pac,
-- ROUND(SUM(Score_indian)/SUM(Score_2),4) AS ratio_indian,
ROUND(SUM(Score_poor)/SUM(Score_2),4) AS ratio_poor,
ROUND(SUM(Score_near_poor)/SUM(Score_2),4) AS ratio_near_poor,
MAX(ISNULL(score_2) AND score_rev>0) AS nogrid
FROM release_cl r LEFT JOIN rsei237gma.release_ej_2017 j USING (ReleaseNumber),
rsei237.Facility f LEFT JOIN alldb.all_naics_cd s ON f.naics1=s.naics
WHERE f.facilitynumber=r.facilitynumber
AND (media<3 OR media=750 OR media=754)
AND year=2017
GROUP BY NAICSCode3Digit  ;

-- ej_version_industry  complete, ranked list of industrys ordered by descending score
SELECT 'begin ej_237_2017_industry' AS ``;
SELECT p.NAICSCode3Digit AS Code,naics_tr AS Industry,
facilities,score_rev,pounds_air_rev,pounds_incin_rev,
ratio_nonwhite,ratio_black,ratio_hisp,ratio_poor,ratio_near_poor
-- ratio_a_pac,ratio_indian,
FROM score_sectors p LEFT JOIN alldb.all_naics_cd n ON p.NAICSCode3Digit=n.naics
ORDER BY score_rev DESC,ratio_nonwhite DESC ;
SELECT 'end ej_237_2017_industry' AS `` ;


-- Manage jointly owned companies (joint ventures) by 
--  duplicating joint companies, 
--  halving their scores and pounds, and 
--  stacking with nonjoint

CREATE TEMPORARY TABLE parent_joint 
SELECT j.rpid,p.final_parent,
COUNT(DISTINCT FacilityID) AS Facilities,
MIN(split) AS split,
SUM(Releases) AS Releases,
SUM(split*score_rev) AS score_rev,
SUM(split*pounds_air_rev) AS pounds_air_rev,
SUM(split*pounds_incin_rev) AS pounds_incin_rev,
SUM(split*score_1) AS score_1,
SUM(split*score_2) AS score_2,
SUM(split*score_whitenh) AS score_whitenh,
SUM(split*score_black) AS score_black,
SUM(split*score_hisp) AS score_hisp,
-- SUM(split*score_asian) AS score_asian,
-- SUM(split*score_pacific) AS score_pacific,
-- SUM(split*score_indian) AS score_indian,
SUM(split*score_poor) AS score_poor,
SUM(split*score_near_poor) AS score_near_poor,
ROUND((1 - SUM(split*Score_whitenh)/SUM(split*score_2)),3) AS ratio_nonwhite,
ROUND(SUM(split*Score_black)/SUM(split*score_2),3) AS ratio_black,
ROUND(SUM(split*Score_hisp)/SUM(split*score_2),3) AS ratio_hisp,
-- -- ROUND(SUM(split*Score_asian + Score_pacific)/SUM(split*score_2),3) AS ratio_a_pac,
-- ROUND(SUM(split*Score_indian)/SUM(split*score_2),3) AS ratio_indian,
ROUND(SUM(split*Score_poor)/SUM(split*score_2),3) AS ratio_poor,
ROUND(SUM(split*Score_near_poor)/SUM(split*score_2),3) AS ratio_near_poor
FROM score_fac j,tri_par_top p
WHERE j.rpid=p.rpid
GROUP BY j.rpid ;


-- ej_version_companies  complete, ranked list of companies ordered by descending score
SELECT 'begin ej_237_2017_company' AS ``;
SELECT @rownum:=@rownum+1 AS rank,j.* 
       FROM parent_joint j,(SELECT @rownum:=0) r 
       ORDER BY score_rev DESC;
SELECT 'end ej_237_2017_company' AS ``;



-- Toxic Companies and Toxic 100
CREATE TEMPORARY TABLE ToxicCompanies_2017_temp
SELECT j.final_parent,rpid,
SUM(Facilities) AS Facilities,
SUM(Releases) AS Releases,
SUM(score_rev) AS Score, 
SUM(pounds_air_rev) AS pounds_air_rev, 
SUM(pounds_incin_rev) AS pounds_incin_rev, 
ROUND((1 - SUM(Score_whitenh)/SUM(score_2)),4) AS ratio_nonwhite,
ROUND(SUM(Score_black)/SUM(score_2),4) AS ratio_black,
ROUND(SUM(Score_hisp)/SUM(score_2),4) AS ratio_hisp,
-- -- ROUND(SUM(Score_asian + Score_pacific)/SUM(score_2),4) AS ratio_a_pac,
-- ROUND(SUM(Score_indian)/SUM(score_2),4) AS ratio_indian,
ROUND(SUM(Score_poor)/SUM(score_2),4) AS ratio_poor,
ROUND(SUM(Score_near_poor)/SUM(score_2),4) AS ratio_near_poor
FROM parent_joint j
GROUP BY rpid
ORDER BY Score DESC ;

CREATE TEMPORARY TABLE ToxicCompanies_2017
SELECT @rownum:=@rownum+1 AS tox100_rank,c.* FROM ToxicCompanies_2017_temp c,(SELECT @rownum:=0) r  ORDER BY Score DESC ;

CREATE TEMPORARY TABLE Toxic100_2017
SELECT @rownum:=@rownum+1 AS tox100_rank,c.* FROM ToxicCompanies_2017_temp c,(SELECT @rownum:=0) r ORDER BY Score DESC LIMIT 100 ;

SELECT @rownum:=@rownum+1,final_parent,tox100_rank,FORMAT(Facilities,0),FORMAT(Releases,0),FORMAT(Score,0),FORMAT(pounds_air_rev,0),FORMAT(pounds_incin_rev,0),FORMAT(ratio_nonwhite,4),FORMAT(ratio_black,4),FORMAT(ratio_hisp,4),FORMAT(ratio_poor,4),FORMAT(ratio_near_poor,4) 
-- FORMAT(ratio_a_pac,4),FORMAT(ratio_indian,4),
FROM Toxic100_2017,(SELECT @rownum:=0) r ORDER BY ratio_nonwhite DESC ;

SELECT @rownum:=@rownum+1,final_parent,tox100_rank,FORMAT(Facilities,0),FORMAT(Releases,0),FORMAT(Score,0),FORMAT(pounds_air_rev,0),FORMAT(pounds_incin_rev,0),FORMAT(ratio_nonwhite,4),FORMAT(ratio_black,4),FORMAT(ratio_hisp,4),FORMAT(ratio_poor,4),FORMAT(ratio_near_poor,4) 
-- FORMAT(ratio_a_pac,4),FORMAT(ratio_indian,4),
FROM Toxic100_2017,(SELECT @rownum:=0) r ORDER BY ratio_poor DESC ;

SELECT @rownum:=@rownum+1,final_parent,tox100_rank,FORMAT(Facilities,0),FORMAT(Releases,0),FORMAT(Score,0),FORMAT(pounds_air_rev,0),FORMAT(pounds_incin_rev,0),FORMAT(ratio_nonwhite,4),FORMAT(ratio_black,4),FORMAT(ratio_hisp,4),FORMAT(ratio_poor,4),FORMAT(ratio_near_poor,4) 
-- FORMAT(ratio_a_pac,4),FORMAT(ratio_indian,4),
FROM Toxic100_2017,(SELECT @rownum:=0) r ORDER BY Score DESC ;




-- Facility within firm
CREATE TEMPORARY TABLE parent_100_facility
SELECT p.final_parent, p.rpid, facilityid, FacilityName, f.city, f.state, tox100_rank, p.score AS parent_score, f.score_rev AS facility_score, f.score_2 AS facility_score_alt, f.score_whitenh, f.score_poor, f.score_near_poor, f.score_black, f.score_hisp, f.split, f.nogrid
-- f.score_asian,f.score_pacific, f.score_indian, 
FROM score_fac f, ToxicCompanies_2017 p
WHERE f.rpid=p.rpid
ORDER BY parent_score DESC, facility_score DESC, final_parent ;


-- Chemical within firm (joint adjusted)
CREATE TEMPORARY TABLE parent_100_chemical
SELECT p.final_parent, p.rpid, cas, casstandard, chemical, tox100_rank, 
MAX(p.score) AS parent_score, 
SUM(c.score_rev) AS chemical_score, 
SUM(c.score_2) AS chemical_score_alt, 
SUM(c.score_whitenh) AS score_whitenh, 
SUM(c.score_poor) AS score_poor, 
SUM(c.score_near_poor) AS score_near_poor, 
SUM(c.score_black) AS score_black, 
SUM(c.score_hisp) AS score_hisp,
-- SUM(c.score_asian) AS score_asian,
-- SUM(c.score_pacific) AS score_pacific, 
-- SUM(c.score_indian) AS score_indian, 
MIN(c.split) AS split,
MAX(nogrid) AS nogrid
FROM score_chem_company c, ToxicCompanies_2017 p
WHERE c.rpid=p.rpid
GROUP BY rpid,cas
ORDER BY parent_score DESC, chemical_score DESC, chemical ;


-- facilities: Air Scores by Parent, and within Parent by Facility, Toxic 100' ;
SELECT 'begin ej_237_2017_company-facility' AS `` ;
SELECT final_parent, rpid,  facilityid, FacilityName ,city, state,split, nogrid, tox100_rank, parent_score, facility_score,
1 - (score_whitenh / facility_score_alt) AS ratio_nonwhite,
score_poor / facility_score_alt AS ratio_poor,
score_near_poor / facility_score_alt AS ratio_near_poor,
score_black / facility_score_alt AS ratio_black,
score_hisp / facility_score_alt AS ratio_hisp
-- -- (score_asian + score_pacific) / facility_score_alt,
-- score_indian / facility_score_alt
FROM parent_100_facility 
ORDER BY parent_score DESC, facility_score DESC, final_parent ;
SELECT 'end ej_237_2017_company-facility' AS `` ;


-- chemical: Air Scores by Parent, and within Parent by Chemical, Toxic 100' ;
SELECT 'begin ej_237_2017_company-chemical' AS `` ;
SELECT final_parent, rpid, cas,casstandard,chemical,split,nogrid,
tox100_rank, parent_score, chemical_score,
1 - (score_whitenh / chemical_score_alt) AS ratio_nonwhite,
score_poor / chemical_score_alt AS ratio_poor,
score_near_poor / chemical_score_alt AS ratio_near_poor,
score_black / chemical_score_alt AS ratio_black,
score_hisp / chemical_score_alt AS ratio_hisp
-- -- (score_asian + score_pacific) / chemical_score_alt,
-- score_indian / chemical_score_alt
FROM parent_100_chemical
ORDER BY parent_score DESC, chemical_score DESC, chemical ;
SELECT 'end ej_237_2017_company-chemical' AS `` ;


-- Chemical-Facility within firm becomes facility-chemical
-- facility-chemical: Air Scores by Parent, and within Parent by Facility-Chemical scores, Toxic 100'
--  Merge parent with release_cl: parent scores by facility-chemical scores for Toxic 100

CREATE TEMPORARY TABLE rj 
SELECT *,(ISNULL(score_1) AND score_rev>0) AS nogrid FROM release_cl r LEFT JOIN rsei237gma.release_ej_2017 j USING (releasenumber) 
WHERE r.year=2017
AND (r.media<3 OR r.media=750 OR r.media=754) ;

CREATE INDEX facilitynumber ON rj (facilitynumber) ;
CREATE INDEX chemicalnumber ON rj (chemicalnumber) ;


-- CREATE TEMPORARY TABLE parent_100_release
SELECT 'begin ej_237_2017_company-facility-chemical' AS `` ;
SELECT p.final_parent, p.rpid, f.FacilityName, f.facilityid, c.casstandard, IF(CASNumber LIKE 'N%',CASNumber,LPAD(CASNumber,9,"0")) AS cas,chemical, 
tox100_rank,parent_score, facility_score, 
SUM(( rj.media<3) * rj.pounds_rev ) AS pounds_air_rev,
SUM(( rj.media=750 OR rj.media=754) * rj.pounds_rev ) AS pounds_incin_rev,
SUM(score_rev ) AS score_rev,
1 - (SUM(IFNULL(ratio_rev,1)*rj.score_whitenh) / SUM(score_2)) AS ratio_nonwhite,
SUM(IFNULL(ratio_rev,1)*rj.score_poor) / SUM(score_2) AS ratio_poor,
SUM(IFNULL(ratio_rev,1)*rj.score_near_poor) / SUM(score_2) AS ratio_near_poor,
SUM(IFNULL(ratio_rev,1)*rj.score_black) / SUM(score_2) AS ratio_black,
SUM(IFNULL(ratio_rev,1)*rj.score_hisp) / SUM(score_2) AS ratio_hisp,
-- -- SUM(IFNULL(ratio_rev,1)*(rj.score_asian + rj.score_pacific)) / SUM(score_2),
-- SUM(IFNULL(ratio_rev,1)*rj.score_indian) / SUM(score_2),
MIN(split) AS split,
MAX(rj.nogrid)
FROM parent_100_facility p, rsei237.Facility f, rsei237.Chemical c, rj 
WHERE p.facilityID = f.facilityID
AND f.facilitynumber=rj.facilitynumber
AND c.chemicalnumber=rj.chemicalnumber
-- AND j.releasenumber=r.releasenumber
GROUP BY p.rpid, facilityid, casstandard
ORDER BY parent_score DESC, facility_score DESC, score_rev DESC, final_parent ;
SELECT 'end ej_237_2017_company-facility-chemical' AS `` ;




-- Exxon Top 5
CREATE TEMPORARY TABLE ExxonTop5
SELECT 
FacilityID,FacilityName,f.city,f.state,
MIN(split) AS split,
SUM(score_rev) AS Score, 
SUM(pounds_air_rev) AS pounds_air_rev, 
SUM(pounds_incin_rev) AS pounds_incin_rev, 
ROUND((1 - SUM(Score_whitenh)/SUM(score_2)),4) AS ratio_nonwhite,
ROUND(SUM(Score_black)/SUM(score_2),4) AS ratio_black,
ROUND(SUM(Score_hisp)/SUM(score_2),4) AS ratio_hisp,
-- -- ROUND(SUM(Score_asian + Score_pacific)/SUM(score_2),4) AS ratio_a_pac,
-- ROUND(SUM(Score_indian)/SUM(score_2),4) AS ratio_indian,
ROUND(SUM(Score_poor)/SUM(score_2),4) AS ratio_poor,
ROUND(SUM(Score_near_poor)/SUM(score_2),4) AS ratio_near_poor
FROM score_fac f, tri_par_top tp
WHERE f.rpid = tp.rpid
AND (tp.final_parent LIKE "EXXON%" OR tp.rpid="1080944" OR tp.first_y50="1080944" OR tp.second_y50="1080944")
GROUP BY tp.final_parent,FacilityID
ORDER BY Score DESC
LIMIT 5 ;


-- Rest of Exxon
CREATE TEMPORARY TABLE ExxonRest
SELECT
"--" AS FacilityID,concat(COUNT(*)," Additional Facilities") AS facility_name,"--" AS city,"--" AS state,
MIN(split) AS split,
SUM(score_rev) AS Score,
SUM(pounds_air_rev) AS pounds_air_rev, 
SUM(pounds_incin_rev) AS pounds_incin_rev, 
ROUND((1 - SUM(Score_whitenh)/SUM(score_2)),4) AS ratio_nonwhite,
ROUND(SUM(Score_black)/SUM(score_2),4) AS ratio_black,
ROUND(SUM(Score_hisp)/SUM(score_2),4) AS ratio_hisp,
-- -- ROUND(SUM(Score_asian + Score_pacific)/SUM(score_2),4) AS ratio_a_pac,
-- ROUND(SUM(Score_indian)/SUM(score_2),4) AS ratio_indian,
ROUND(SUM(Score_poor)/SUM(score_2),4) AS ratio_poor,
ROUND(SUM(Score_near_poor)/SUM(score_2),4) AS ratio_near_poor
FROM
(SELECT
MIN(split) AS split,
SUM(split*score_rev) AS score_rev,
SUM(split*pounds_air_rev) AS pounds_air_rev, 
SUM(split*pounds_incin_rev) AS pounds_incin_rev, 
SUM(split*score_1) AS score_1,
SUM(split*score_2) AS score_2,
SUM(split*Score_whitenh) AS Score_whitenh,
SUM(split*Score_black) AS Score_black,
SUM(split*Score_hisp) AS Score_hisp,
-- SUM(split*Score_asian) AS Score_asian,
-- SUM(split*Score_pacific) AS Score_pacific,
-- SUM(split*Score_indian) AS Score_indian,
SUM(split*Score_poor) AS Score_poor,
SUM(split*Score_near_poor) AS Score_near_poor
FROM score_fac f, tri_par_top tp
WHERE f.rpid = tp.rpid
AND (tp.final_parent LIKE "EXXON%" OR tp.rpid="1080944" OR tp.first_y50="1080944" OR tp.second_y50="1080944")
GROUP BY tp.final_parent,FacilityID
ORDER BY score_1 DESC
LIMIT 5,10000) rest ;



-- All of Exxon
CREATE TEMPORARY TABLE ExxonAll
SELECT
"--" AS FacilityID,concat(COUNT(*)," Total Facilities") AS facility_name,"--" AS city,"--" AS state,
MIN(split) AS split,
SUM(score_rev) AS Score,
SUM(pounds_air_rev) AS pounds_air_rev,
SUM(pounds_incin_rev) AS pounds_incin_rev,
ROUND((1 - SUM(Score_whitenh)/SUM(score_2)),4) AS ratio_nonwhite,
ROUND(SUM(Score_black)/SUM(score_2),4) AS ratio_black,
ROUND(SUM(Score_hisp)/SUM(score_2),4) AS ratio_hisp,
-- -- ROUND(SUM(Score_asian + Score_pacific)/SUM(score_2),4) AS ratio_a_pac,
-- ROUND(SUM(Score_indian)/SUM(score_2),4) AS ratio_indian,
ROUND(SUM(Score_poor)/SUM(score_2),4) AS ratio_poor,
ROUND(SUM(Score_near_poor)/SUM(score_2),4) AS ratio_near_poor
FROM
(SELECT
MIN(split) AS split,
SUM(split*score_rev) AS score_rev,
SUM(split*pounds_air_rev) AS pounds_air_rev, 
SUM(split*pounds_incin_rev) AS pounds_incin_rev, 
SUM(split*score_1) AS score_1,
SUM(split*score_2) AS score_2,
SUM(split*Score_black) AS Score_black,
SUM(split*Score_hisp) AS Score_hisp,
-- SUM(split*Score_asian) AS Score_asian,
-- SUM(split*Score_pacific) AS Score_pacific,
-- SUM(split*Score_indian) AS Score_indian,
SUM(split*Score_whitenh) AS Score_whitenh,
SUM(split*Score_poor) AS Score_poor,
SUM(split*Score_near_poor) AS Score_near_poor
FROM score_fac f, tri_par_top tp
WHERE f.rpid = tp.rpid
AND (tp.final_parent LIKE "EXXON%" OR tp.rpid="1080944" OR tp.first_y50="1080944" OR tp.second_y50="1080944") 
GROUP BY tp.final_parent,FacilityID
ORDER BY score_1 DESC) exxon ;

SELECT 'begin ej_237_2017_exxon' AS `` ;
(SELECT * FROM ExxonTop5 ) UNION (SELECT * FROM ExxonRest ) UNION (SELECT * FROM ExxonAll ) ;
SELECT 'end ej_237_2017_exxon' AS `` ;
