USE match20171;

-- Surface water and POTW pounds, Drinking Water Scores by Parent Company

-- Create temp table of pounds released to surface water and transferred to POTW, by facility
CREATE TEMPORARY TABLE pounds_fac
SELECT rpid,final_parent,f.facilityid, Facility_Name, f.street, f.city, f.state, MIN(split) AS split,
SUM( (media=3) * PoundsReleased) AS pounds_surf, SUM(( media=3) * pounds_rev) AS pounds_surf_rev,
SUM( (media=6) * PoundsReleased) AS pounds_potw, SUM(( media=6) * pounds_rev) AS pounds_potw_rev,
SUM( ((media=3)+(media=6)*IFNULL((1-POTWPartitionRemoval/100),0))  * PoundsReleased * IFNULL(otw,0)) AS hazard, 
SUM( ((media=3)+(media=6)*IFNULL((1-POTWPartitionRemoval/100),0))  * pounds_rev * IFNULL(otw,0)) AS hazard_rev,
-- SUM( ((media=3)+(media=6)*IFNULL((1-POTWPartitionRemoval/100),0))  * pounds_rev * IFNULL(otw,0) * population) AS hazard_pop_rev,
SUM( ((media=3)+(media=6)*IFNULL((1-POTWPartitionRemoval/100),0))  * PoundsReleased ) AS poundspt,
SUM( ((media=3)+(media=6)*IFNULL((1-POTWPartitionRemoval/100),0))  * pounds_rev ) AS poundspt_rev
FROM release_cl r, rsei235.Facility f, rsei235.Chemical c, tri_par_basic t
WHERE f.facilitynumber=r.facilitynumber
AND c.chemicalnumber=r.chemicalnumber
AND f.facilityid=t.facility_id
AND year=2015
GROUP BY rpid,facilityid ;

-- Create temp table of revised (and unrevised) water scores, by facility

CREATE TEMPORARY TABLE score_dw_fac
SELECT rpid,f.facilityID, 
SUM(score) AS score, SUM(score_rev) AS score_rev,
-- SUM(poundspt_rev * IFNULL(otw,0)) AS hazard_rev,SUM(poundspt_rev) AS poundspt_rev,
SUM(poundspt_rev*IFNULL(otw,0)*population) AS hazard_pop_rev, 
MIN(ratio_rev) AS rev_d,MAX(ratio_rev) AS rev_u
FROM elements_cl e, rsei235.Facility f, rsei235.Chemical c, tri_par_basic t
WHERE f.facilitynumber=e.facilitynumber
AND f.facilityid=t.facility_id
AND c.chemicalnumber=e.chemicalnumber
AND (ScoreCategory=5
	OR ScoreCategory=7
	OR ScoreCategory=205
	OR ScoreCategory=207)
AND year=2015
GROUP BY rpid,f.facilityid;

--  Merge temp tables to get water data by facility
CREATE TEMPORARY TABLE score_fac
SELECT * 
FROM pounds_fac p LEFT JOIN score_dw_fac s USING (rpid,facilityid) ;

-- Add up facilities to get companies
CREATE TEMPORARY TABLE parent
SELECT final_parent, rpid, 
SUM(split*pounds_surf) AS pounds_surf, SUM(split*pounds_surf_rev) AS pounds_surf_rev, 
SUM(split*pounds_potw) AS pounds_potw, SUM(split*pounds_potw_rev) AS pounds_potw_rev, 
SUM(split*score) AS score, SUM(split*score_rev) AS score_rev,SUM(split*hazard_rev) AS hazard_rev,SUM(split*hazard_pop_rev) AS hazard_pop_rev,SUM(split*poundspt_rev) AS poundspt_rev,
MIN(split) AS split,
MIN(rev_d) AS rev_d,MAX(rev_u) AS rev_u
FROM score_fac
GROUP BY rpid ;

-- Create temp table of pounds released to surface water and transferred to POTW, by chemical and company
CREATE TEMPORARY TABLE pounds_chem
SELECT rpid,final_parent,c.casstandard, c.cas,chemical,
MIN(split) AS split,
COUNT(*) AS Releases,
SUM(split* (media=3) * PoundsReleased) AS pounds_surf, SUM(split*( media=3) * pounds_rev) AS pounds_surf_rev,
SUM(split* (media=6) * PoundsReleased) AS pounds_potw, SUM(split*( media=6) * pounds_rev) AS pounds_potw_rev,
SUM(split* ((media=3)+(media=6)*IFNULL((1-POTWPartitionRemoval/100),0))  * PoundsReleased * IFNULL(otw,0)) AS hazard, 
SUM(split* ((media=3)+(media=6)*IFNULL((1-POTWPartitionRemoval/100),0))  * pounds_rev * IFNULL(otw,0)) AS hazard_rev,
SUM(split* ((media=3)+(media=6)*IFNULL((1-POTWPartitionRemoval/100),0))  * PoundsReleased ) AS poundspt,
SUM(split* ((media=3)+(media=6)*IFNULL((1-POTWPartitionRemoval/100),0))  * pounds_rev ) AS poundspt_rev
FROM release_cl r, rsei235.Chemical c, tri_par_basic t
WHERE t.facility_ID=r.facilityID
AND c.chemicalnumber=r.chemicalnumber
AND year=2015
GROUP BY rpid,cas;

-- Create temp table of revised (and unrevised) drinking water scores, by chemical and company
CREATE TEMPORARY TABLE score_dw_chem
SELECT rpid,c.cas,
MIN(split) AS sdc_split,
SUM(split*score) AS score,
SUM(split*score_rev) AS score_rev,
-- SUM(split*poundspt_rev * IFNULL(otw,0)) AS hazard_rev,
SUM(split*poundspt_rev*IFNULL(otw,0)*population) AS hazard_pop_rev, 
-- SUM(split*poundspt_rev) AS poundspt_rev,
MIN(ratio_rev) AS rev_d,MAX(ratio_rev) AS rev_u
FROM elements_cl e, tri_par_basic t, rsei235.Chemical c
WHERE t.facility_id=e.FacilityID
AND c.chemicalnumber=e.chemicalnumber
AND (ScoreCategory=5
	OR ScoreCategory=7
	OR ScoreCategory=205
	OR ScoreCategory=207)
AND year=2015
GROUP BY rpid,cas ;


SELECT * FROM pounds_chem LIMIT 10 ;
SELECT * FROM score_dw_chem LIMIT 10 ;


CREATE TEMPORARY TABLE score_chem
SELECT *
FROM pounds_chem p LEFT JOIN score_dw_chem s USING(rpid,cas) ;


-- Extract top 100 (using joint-venture corrected data)
CREATE TEMPORARY TABLE parent100
SELECT @rownum:=@rownum+1 AS rank, j.* 
FROM parent j,(SELECT @rownum:=0) r  
-- N.B. matters a lot if we order by score or hazard!!!
ORDER BY hazard_rev DESC
;

SELECT 'begin water_235_2015_parent' AS comment ;
SELECT rank,final_parent,rpid,
hazard_rev,pounds_surf_rev, pounds_potw_rev,poundspt_rev,split,rev_d,rev_u
FROM parent100 ORDER BY hazard_rev DESC ;
SELECT 'end water_235_2015_parent' AS comment ;

-- Drinking Water Scores by Facility within Parent Company (joint-modified)

CREATE TEMPORARY TABLE parent_100_facility
SELECT p.final_parent, p.rpid, facilityid, Facility_Name, f.street, f.city, f.state, 
p.score_rev AS parent_score, p.hazard_rev AS parent_hazard, p.hazard_pop_rev AS parent_hazard_pop, 
f.score_rev AS facility_score,
f.hazard_rev AS facility_hazard, 
f.hazard_pop_rev AS facility_hazard_pop,
f.pounds_surf_rev AS facility_pounds_surf_rev,
f.pounds_potw_rev AS facility_pounds_potw_rev,
f.poundspt_rev AS facility_poundspt_rev,
f.split,f.rev_d,f.rev_u
FROM score_fac f, parent100 p
WHERE f.rpid=p.rpid ;

SELECT 'begin water_235_2015_parent-facility' AS comment ;
SELECT rpid,facilityID,final_parent,Facility_Name,city,state,
parent_hazard,
facility_hazard,
facility_pounds_surf_rev, facility_pounds_potw_rev, facility_poundspt_rev,
split,rev_d,rev_u
FROM parent_100_facility
ORDER BY parent_hazard DESC, facility_hazard DESC, final_parent ;
SELECT 'end water_235_2015_parent-facility' AS comment ;


-- Water Scores by Parent, and within Parent by Chemical scores  (joint-modified)
CREATE TEMPORARY TABLE parent_100_chemical
SELECT p.final_parent, p.rpid, c.cas, chemical,
MAX(p.score_rev) AS parent_score, MAX(p.hazard_rev) AS parent_hazard, MAX(p.hazard_pop_rev) AS parent_hazard_pop, 
SUM(c.score_rev) AS chemical_score,SUM(c.hazard_rev) AS chemical_hazard, SUM(c.hazard_pop_rev) AS chemical_hazard_pop,
SUM(c.pounds_surf_rev) AS chemical_pounds_surf_rev, SUM(c.pounds_potw_rev) AS chemical_pounds_potw_rev, SUM(c.poundspt_rev) AS chemical_poundspt_rev,
MAX(c.split) AS split,MAX(c.rev_d) AS rev_d,MAX(c.rev_u) AS rev_u
FROM score_chem c, parent100 p
WHERE c.rpid=p.rpid
GROUP BY rpid,c.cas;

SELECT 'begin water_235_2015_parent-chemical' AS comment ;
SELECT rpid,final_parent,cas,chemical,
parent_hazard,
chemical_hazard,
chemical_pounds_surf_rev, chemical_pounds_potw_rev, chemical_poundspt_rev,
split,rev_d,rev_u
FROM parent_100_chemical
ORDER BY parent_hazard DESC, chemical_hazard DESC, final_parent ;
SELECT 'end water_235_2015_parent-chemical' AS comment ;


-- Water Scores by Parent, and within Parent by Facility-Chemical scores
-- Merge parent with release_cl: parent and drinking water scores by facility-chemical scores

CREATE TEMPORARY TABLE pounds_parent_100_release
SELECT p.final_parent, p.rpid, p.Facility_Name, f.facilityid, f.city, f.state,
c.casstandard, c.cas, chemical, 
parent_score, parent_hazard, parent_hazard_pop,
facility_score, facility_hazard,facility_hazard_pop,
SUM( (media=3) * PoundsReleased) AS pounds_surf, SUM(( media=3) * pounds_rev) AS pounds_surf_rev,
SUM( (media=6) * PoundsReleased) AS pounds_potw, SUM(( media=6) * pounds_rev) AS pounds_potw_rev,
SUM( ((media=3)+(media=6)*IFNULL((1-POTWPartitionRemoval/100),0))  * PoundsReleased * IFNULL(otw,0)) AS hazard, 
SUM( ((media=3)+(media=6)*IFNULL((1-POTWPartitionRemoval/100),0))  * pounds_rev * IFNULL(otw,0)) AS hazard_rev,
-- SUM( ((media=3)+(media=6)*IFNULL((1-POTWPartitionRemoval/100),0))  * pounds_rev * IFNULL(otw,0) * population) AS hazard_pop_rev,
SUM( ((media=3)+(media=6)*IFNULL((1-POTWPartitionRemoval/100),0))  * PoundsReleased ) AS poundspt,
SUM( ((media=3)+(media=6)*IFNULL((1-POTWPartitionRemoval/100),0))  * pounds_rev ) AS poundspt_rev
FROM parent_100_facility p, rsei235.Facility f, rsei235.Chemical c, release_cl r
WHERE p.facilityID = f.facilityID
AND f.facilitynumber=r.facilitynumber
AND c.chemicalnumber=r.chemicalnumber
AND (media=3 OR media=6)
AND year=2015
GROUP BY rpid, facilityid, c.casstandard ;

CREATE INDEX `release` ON pounds_parent_100_release (rpid, facilityid, casstandard) ;

CREATE TEMPORARY TABLE score_parent_100_release
SELECT p.rpid, f.facilityid, c.casstandard, c.cas,
SUM(e.score) AS score, SUM(e.score_rev) AS score_rev, 
-- SUM(e.poundspt_rev * IFNULL(otw,0)) AS hazard_rev,
SUM(poundspt_rev*IFNULL(otw,0)*population) AS hazard_pop_rev
-- SUM(poundspt_rev) AS poundspt_rev
FROM parent_100_facility p, rsei235.Facility f, rsei235.Chemical c, elements_cl e
WHERE p.facilityid=f.facilityID
AND f.facilitynumber=e.facilitynumber
AND c.chemicalnumber=e.chemicalnumber
AND (media=3 OR media=6)
AND (ScoreCategory=5
	OR ScoreCategory=7
	OR ScoreCategory=205
	OR ScoreCategory=207)
AND year=2015
GROUP BY p.rpid, facilityid, casstandard ;

CREATE INDEX `release` ON score_parent_100_release (rpid, facilityid, casstandard) ;

SELECT 'begin water_235_2015_parent-facility-chemical' AS comment ;
SELECT p.final_parent,p.rpid,p.Facility_Name,p.city,p.state,p.facilityID,chemical,p.cas,
parent_hazard,
facility_hazard,
hazard_rev,
pounds_surf_rev,pounds_potw_rev,poundspt_rev
FROM pounds_parent_100_release p LEFT JOIN score_parent_100_release s 
     ON s.rpid=p.rpid AND s.facilityid=p.facilityid AND s.casstandard=p.casstandard
ORDER BY parent_hazard DESC, facility_hazard DESC, hazard_rev DESC, final_parent ;
SELECT 'end water_235_2015_parent-facility-chemical' AS comment ;


SELECT p.final_parent,p.Facility_Name,p.facilityID,chemical,
parent_score,facility_score,score_rev,hazard_rev,hazard_pop_rev,pounds_surf_rev,pounds_potw_rev,PublicContactName,PublicContactPhone
FROM pounds_parent_100_release p LEFT JOIN score_parent_100_release s 
     ON s.rpid=p.rpid AND s.facilityid=p.facilityid AND s.casstandard=p.casstandard
     LEFT JOIN rsei235.Facility f ON s.facilityID=f.facilityID
WHERE score_rev / parent_score > 0.50 OR hazard_rev / parent_hazard > 0.50
ORDER BY parent_hazard DESC, facility_hazard DESC, hazard_rev DESC, final_parent ;
