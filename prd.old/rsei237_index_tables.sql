USE ashm_rsei237 ;

-- DROP INDEX Media on Media ;
-- DROP INDEX FacilityNumber ON Facility ;
-- DROP INDEX FacilityID ON Facility ;
-- DROP INDEX ChemicalNumber ON Chemical ;
-- DROP INDEX CASNumber ON Chemical ;
-- DROP INDEX CASStandard ON Chemical ;
-- DROP INDEX ElementNumber on Elements ;
-- DROP INDEX ReleaseNumber on Elements ;

-- ALTER TABLE Chemical DROP COLUMN cas ;
ALTER TABLE Chemical ADD COLUMN cas VARCHAR(9), MODIFY CASNumber VARCHAR(15), MODIFY CASStandard VARCHAR(15);
UPDATE Chemical SET cas = IF(CASNumber LIKE 'N%',CASNumber,LPAD(CASNumber,9,"0")) ;

ALTER TABLE Facility MODIFY FacilityID VARCHAR(15) NOT NULL ;


CREATE UNIQUE INDEX Media ON Media (Media) ;

CREATE UNIQUE INDEX FacilityNumber ON Facility (FacilityNumber) ;
CREATE UNIQUE INDEX FacilityID ON Facility (FacilityID) ;
CREATE UNIQUE INDEX ChemicalNumber ON Chemical (ChemicalNumber) ;
CREATE UNIQUE INDEX CASNumber ON Chemical (CASNumber) ;
CREATE UNIQUE INDEX CASStandard ON Chemical (CASStandard) ;
CREATE UNIQUE INDEX cas ON Chemical (cas) ;

CREATE UNIQUE INDEX ElementNumber ON `Elements` (ElementNumber) ;
CREATE INDEX ReleaseNumber ON `Elements` (ReleaseNumber) ;

CREATE UNIQUE INDEX ReleaseNumber ON `Releases` (ReleaseNumber) ;
CREATE INDEX SubmissionNumber ON `Releases` (SubmissionNumber) ;

CREATE UNIQUE INDEX SubmissionNumber ON Submission (SubmissionNumber) ;
CREATE INDEX FacilityNumber ON Submission (FacilityNumber) ;
CREATE INDEX ChemicalNumber ON Submission (ChemicalNumber) ;


