USE match20171;

-- Surface water and POTW pounds by Parent Company

-- Create temp table of pounds released to surface water and transferred to POTW, by facility
CREATE TEMPORARY TABLE pounds_fac
SELECT year,rpid,final_parent,f.facilityid, Facility_Name, f.street, f.city, f.state, MIN(split) AS split,
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
GROUP BY rpid,facilityid,year ;

-- Add up facilities to get companies
CREATE TEMPORARY TABLE parent
SELECT year,final_parent, rpid, 
SUM(split*pounds_surf) AS pounds_surf, SUM(split*pounds_surf_rev) AS pounds_surf_rev, 
SUM(split*pounds_potw) AS pounds_potw, SUM(split*pounds_potw_rev) AS pounds_potw_rev, 
SUM(split*hazard_rev) AS hazard_rev,SUM(split*poundspt_rev) AS poundspt_rev,
MIN(split) AS split
FROM pounds_fac
GROUP BY rpid,year ;


SELECT year,SUM(pounds_surf_rev),SUM(pounds_potw_rev),SUM(poundspt_rev)-SUM(pounds_surf_rev),SUM(poundspt_rev) FROM parent GROUP BY year ORDER BY year;

