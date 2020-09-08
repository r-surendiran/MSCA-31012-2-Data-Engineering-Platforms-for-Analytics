/***********************************************
**                MSc ANALYTICS 
**     DATA ENGINEERING PLATFORMS (MSCA 31012-2)
** File:   Final Project Nornalized EER DDL&DML 
** Desc:   DDL/ DML for the Final Project Normalized data with data cleaning and preparation
** Auth:   Team 1
** Date:   05/24/2020
** ALL RIGHTS RESERVED | DO NOT DISTRIBUTE
************************************************/

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL,ALLOW_INVALID_DATES';

DROP DATABASE IF EXISTS `final_project_covid_norm` ;
CREATE DATABASE  IF NOT EXISTS `final_project_covid_norm` 
/*!40100 DEFAULT CHARACTER SET utf8 */ /*!80016 DEFAULT ENCRYPTION='N' */;
USE `final_project_covid_norm`;

####################################################################################
##Table1  - Symptoms
##Fetch Unique Symptom Details from the source tables(Survey and Covid tables)
####################################################################################
###              DDL                  ####
##########################################
DROP TABLE IF EXISTS final_project_covid_norm.symptoms;
CREATE TABLE final_project_covid_norm.symptoms (
  `symptom_id` BIGINT NOT NULL AUTO_INCREMENT,
  `symptom_type` VARCHAR(250) NOT NULL,
  PRIMARY KEY (`symptom_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8
;
CREATE INDEX `symptom_type_idx` ON `final_project_covid_norm`.`symptoms` (`symptom_type` ASC);

##########################################
###              DML                  ####
##########################################

TRUNCATE TABLE final_project_covid_norm.symptoms;
INSERT INTO final_project_covid_norm.symptoms (symptom_type) 
##CREATE TABLE final_project_covid_norm.symptoms AS
SELECT symptom_type
FROM 
 ( 
SELECT DISTINCT 
  TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(cau1.symptom_type, ',', numbers.num), ',', -1)) AS symptom_type
FROM
  (SELECT 1 AS num UNION ALL SELECT 2
   UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7) numbers INNER JOIN 
(
SELECT DISTINCT TRIM(primary_cause) AS symptom_type FROM covid.covid pc
UNION
SELECT DISTINCT TRIM(primary_cause_line_A) AS symptom_type FROM covid.covid pc
UNION
SELECT DISTINCT TRIM(primary_cause_line_B) AS symptom_type FROM covid.covid pc
UNION
SELECT DISTINCT TRIM(primary_cause_line_C) AS symptom_type FROM covid.covid pc
UNION
SELECT DISTINCT TRIM(secondary_cause) AS symptom_type FROM covid.covid pc
UNION
SELECT DISTINCT TRIM(secondary_cause) AS symptom_type FROM covid.covid pc
) cau1 
  ON CHAR_LENGTH(cau1.symptom_type)
     -CHAR_LENGTH(REPLACE(cau1.symptom_type, ',', ''))>=numbers.num-1
WHERE TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(cau1.symptom_type, ',', numbers.num), ',', -1)) <> ''
ORDER BY num ) cau
WHERE COALESCE(TRIM(cau.symptom_type),'') NOT IN ('','.')
ORDER BY cau.symptom_type
;

###########################
## Load symptoms from Survey
###########################
INSERT INTO final_project_covid_norm.symptoms (symptom_type) VALUES ("fever"),("dry cough"),("flu"),("shortness of breath"),("decreased smell taste");

######################################
### Table 3: AGE GROUP Table 
### Fetch Unique Age_group from survey, Derive age_group_nbr and generation
######################################
##########################################
###              DDL                  ####
##########################################
DROP TABLE IF EXISTS final_project_covid_norm.age_group;
CREATE TABLE final_project_covid_norm.age_group (
  `age_grp_id` BIGINT NOT NULL AUTO_INCREMENT,
  `age_grp_yr` VARCHAR(14) NOT NULL,
  `age_grp_nbr` VARCHAR(10) NOT NULL,
  `age_grp_gen` VARCHAR(25) NOT NULL,
  PRIMARY KEY (`age_grp_id`)
) ENGINE=InnoDB
ENGINE = InnoDB
AUTO_INCREMENT = 401
DEFAULT CHARACTER SET = utf8;
;
CREATE INDEX `age_grp_yr_idx` ON `final_project_covid_norm`.`age_group` (`age_grp_yr` ASC);

##########################################
###              DML                  ####
##########################################

TRUNCATE TABLE final_project_covid_norm.age_group;
INSERT INTO final_project_covid_norm.age_group (age_grp_yr,age_grp_nbr,age_grp_gen) 

SELECT agp.age_grp_yr ,agp.age_grp_nbr,agp.age_grp_gen
FROM (
SELECT DISTINCT
       CASE WHEN age_group = '1943 - 1923' THEN '1923 - 1943' 
            ELSE age_group END AS age_grp_yr ,
       CASE WHEN age_group = '1943 - 1923' THEN 'OVER 77' 
			WHEN age_group = '1944 - 1964' THEN '56-76' 
            WHEN age_group = '1965 - 1979' THEN '41-55' 
            WHEN age_group = '1980 - 1994' THEN '26-40' 
            WHEN age_group = '1995 - 2015' THEN '5-25' 
            ELSE '0-5' END as age_grp_nbr,
       CASE WHEN age_group = '1943 - 1923' THEN 'The Silent Generation' 
			WHEN age_group = '1944 - 1964' THEN 'Baby Boomers' 
            WHEN age_group = '1965 - 1979' THEN 'Gen X' 
            WHEN age_group = '1980 - 1994' THEN 'MILLENIAL' 
            WHEN age_group = '1995 - 2015' THEN 'Gen Z' 
            ELSE 'Gen Alpha ' END as age_grp_gen
FROM covid.survey svy) agp
;
######################################
### Table 4: RACE Table 
######################################
/*DROP TABLE IF EXISTS final_project_covid_norm.race;
CREATE TABLE final_project_covid_norm.race AS
SELECT @n := @n + 1 AS  race_id ,rc.race_nm
FROM (
   SELECT DISTINCT 
              CASE WHEN 'American Indian or Alaska Native' THEN 'American Indian' WHEN 'Native Hawaiian or Pacific Islander' THEN 'Native Hawaiian' ELSE  race END  AS race_nm
	 FROM covid.survey, (SELECT @n := 0) m   
     WHERE coalesce(trim(race),'') NOT IN ('') ) rc;           
*/

##########################################
###              DDL                  ####
##########################################
DROP TABLE IF EXISTS final_project_covid_norm.race;
CREATE TABLE final_project_covid_norm.race (
  `race_id` BIGINT NOT NULL AUTO_INCREMENT,
  `race_nm` VARCHAR(30) NOT NULL,
  PRIMARY KEY (`race_id`)
) ENGINE=InnoDB AUTO_INCREMENT = 501 DEFAULT CHARSET=utf8;

CREATE INDEX `race_nm_idx` ON `final_project_covid_norm`.`race` (`race_nm` ASC);
##########################################
###              DML                  ####
##########################################
TRUNCATE TABLE final_project_covid_norm.race;
INSERT INTO final_project_covid_norm.race (race_nm) VALUES ('Asian'),('Black'),('Latinx'),('White'),('American Indian'),('Native Hawaiian'),('Other')
;

###############################################
### Table 5: Education Level  
### Fetch the education information from survey. 
###############################################
##########################################
###              DDL                  ####
##########################################
DROP TABLE IF EXISTS final_project_covid_norm.education;
CREATE TABLE final_project_covid_norm.education (
  `education_id` BIGINT NOT NULL AUTO_INCREMENT,
  `education_level` VARCHAR(175) NOT NULL,
  PRIMARY KEY (`education_id`)
) ENGINE=InnoDB AUTO_INCREMENT = 501 DEFAULT CHARSET=utf8;
##########################################
###              DML                  ####
##########################################
TRUNCATE TABLE final_project_covid_norm.education;
INSERT INTO final_project_covid_norm.education (education_level) 
   SELECT DISTINCT education_level FROM covid.survey WHERE coalesce(trim(education_level),'') NOT IN ('') ;           

######################################
### Table 6: Income Bracket Table
### Fetch the income level from survey 
######################################
##########################################
###              DDL                  ####
##########################################
DROP TABLE IF EXISTS final_project_covid_norm.income;
CREATE TABLE final_project_covid_norm.income (
  `income_id` BIGINT NOT NULL AUTO_INCREMENT,
  `income_bracket` VARCHAR(175) NOT NULL,
  PRIMARY KEY (`income_id`)
) ENGINE=InnoDB AUTO_INCREMENT = 601 DEFAULT CHARSET=utf8;
##########################################
###              DML                  ####
##########################################

TRUNCATE TABLE final_project_covid_norm.income;
INSERT INTO final_project_covid_norm.income (income_bracket) 
SELECT DISTINCT 
       income_bracket 
  FROM covid.survey  
  WHERE coalesce(trim(income_bracket),'') NOT IN ('') 
     ;
   
######################################
### Table 7: problem identifier Table 
### Fetch the problem/seriousness from survey 
### a)Before my state mandated a stay at home order.
### b)After my state mandated a stay-at-home order.
### c)When my state mandated a stay at home order.
### d)It does not feel like a serious problem to me.
######################################
##########################################
###              DDL                  ####
##########################################
DROP TABLE IF EXISTS final_project_covid_norm.problem;
CREATE TABLE final_project_covid_norm.problem (
  `problem_id` BIGINT NOT NULL AUTO_INCREMENT,
  `problem_type` VARCHAR(175) NOT NULL,
  PRIMARY KEY (`problem_id`)
) ENGINE = InnoDB
AUTO_INCREMENT = 701
DEFAULT CHARACTER SET = utf8
;

##########################################
###              DML                  ####
##########################################
TRUNCATE TABLE final_project_covid_norm.problem;
INSERT INTO final_project_covid_norm.problem (problem_type) 
SELECT DISTINCT serious_problem as problem_type 
from covid.survey  
WHERE coalesce(trim(serious_problem),'') NOT IN ('')
;

######################################
### Table 8: County ZIP Table 
### Load all US counties from location world dataset to staging table
### Then load to the county zip entity
######################################
##########################################
###              DDL                  ####
##########################################
##8A## LOAD DATA FILE -- County CSV file from Desktop to staging table ###
DROP TABLE IF EXISTS final_project_covid_norm.county_zip_staging;
CREATE TABLE final_project_covid_norm.county_zip_staging (
  `zip` INT(6) NOT NULL,
  `fips` VARCHAR(10) NOT NULL, 
  `city` VARCHAR(50) NOT NULL,
  `state` VARCHAR(40) NOT NULL, 
  `cty_nm` VARCHAR(50) NOT NULL
) ENGINE = InnoDB

DEFAULT CHARACTER SET = latin1;

SHOW VARIABLES LIKE "secure_file_priv";
TRUNCATE TABLE final_project_covid_norm.county_zip_staging;

LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\Location_DataWorld.csv' 
INTO TABLE final_project_covid_norm.county_zip_staging 
FIELDS TERMINATED BY ',' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(zip, fips, city, state, cty_nm)
;

DROP TABLE IF EXISTS final_project_covid_norm.county_zip;
CREATE TABLE final_project_covid_norm.county_zip (
  `ctyzip_id` BIGINT NOT NULL AUTO_INCREMENT,
  `zip` INT(6) NOT NULL,
  `fips` VARCHAR(10) NOT NULL, 
  `city` VARCHAR(50) NOT NULL,
  `state` VARCHAR(40) NOT NULL, 
  `cty_nm` VARCHAR(50) NOT NULL,
  PRIMARY KEY (`ctyzip_id`)
) ENGINE = InnoDB
AUTO_INCREMENT = 901
DEFAULT CHARACTER SET = latin1;

TRUNCATE TABLE final_project_covid_norm.county_zip;
INSERT INTO final_project_covid_norm.county_zip (zip,fips,city,state,cty_nm) 
 SELECT DISTINCT 
        zip,
        fips,
        city,
        state,
        cty_nm
FROM
(
 SELECT  zip,
        fips,
        city,
        state,
        REPLACE(REPLACE(LOWER(TRIM(cty_nm)), '\r', ''), '\n', '') as cty_nm,
       row_number() over (partition by zip order by fips,cty_nm desc) as toprank
  FROM final_project_covid_norm.county_zip_staging 
) inn
where inn.toprank = 1
;
############################################################################
### Table 9: Address Table 
### Load Nursing home and Medical archive incident address to address table
############################################################################
##########################################
###              DDL                  ####
##########################################
DROP TABLE IF EXISTS final_project_covid_norm.address;
CREATE TABLE final_project_covid_norm.address (
  `address_id` BIGINT NOT NULL AUTO_INCREMENT,
  `address_ln_1` VARCHAR(80) NOT NULL,
  `address_ln_2` VARCHAR(40),
  `ctyzip_id`  BIGINT NOT NULL, 
  PRIMARY KEY (`address_id`),
  CONSTRAINT `ctyzip_fk`
  FOREIGN KEY (`ctyzip_id`)
   REFERENCES `final_project_covid_norm`.`county_zip` (`ctyzip_id`)
) ENGINE = InnoDB
AUTO_INCREMENT = 1001
DEFAULT CHARACTER SET = latin1;

##########################################
###              DML                  ####
##########################################
TRUNCATE TABLE final_project_covid_norm.address;
INSERT INTO final_project_covid_norm.address (address_ln_1,address_ln_2,ctyzip_id) 
 SELECT DISTINCT 
  adr.address_ln_1,
  adr.address_ln_2,
  cz.ctyzip_id AS  ctyzip_id 
  FROM  
 ( SELECT DISTINCT 
	   address  AS address_ln_1,
       ''       AS address_ln_2,
       Zip_code AS zip_cd
  FROM covid.nursing where TRIM(address) <> ''  
  UNION
SELECT DISTINCT 
	   Incident_address  AS address_ln_1,
	   ''                AS address_ln_2,
	   Incident_Zip_code AS zip_cd
  FROM covid.covid where TRIM(Incident_address) <> '' ) adr
  INNER JOIN final_project_covid_norm.county_zip cz
		  ON adr.zip_cd = cz.zip
   ;
   
######################################
### Table 10: news sources Table 
### Fetch news sources details from survey
######################################
##########################################
###              DDL                  ####
##########################################
DROP TABLE IF EXISTS final_project_covid_norm.news_source;
CREATE TABLE final_project_covid_norm.news_source (
  `news_id` BIGINT NOT NULL AUTO_INCREMENT,
  `news_src_name` VARCHAR(175) NOT NULL,
  PRIMARY KEY (`news_id`)
) ENGINE = InnoDB
AUTO_INCREMENT = 801
DEFAULT CHARACTER SET = utf8;
;
##########################################
###              DML                  ####
##########################################
TRUNCATE TABLE final_project_covid_norm.news_source;
INSERT INTO final_project_covid_norm.news_source (news_src_name) 
SELECT DISTINCT 
  TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(survey.news_source, ',', numbers.num), ',', -1)) AS news_src_name
FROM
  (SELECT 1 AS num UNION ALL SELECT 2
   UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7) numbers INNER JOIN covid.survey
  ON CHAR_LENGTH(survey.news_source)
     -CHAR_LENGTH(REPLACE(survey.news_source, ',', ''))>=numbers.num-1
WHERE TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(survey.news_source, ',', numbers.num), ',', -1)) <> ''
ORDER BY num
 ;

######################################
### Table 11: survey Table 
######################################
##########################################
###              DDL                  ####
##########################################
DROP TABLE IF EXISTS final_project_covid_norm.survey;
CREATE TABLE final_project_covid_norm.survey (
  `survey_id` BIGINT NOT NULL,
  `ctyzip_id` BIGINT NOT NULL,
  `age_grp_id` BIGINT NOT NULL,
  `race_id`    BIGINT NOT NULL, 
  `gender`     VARCHAR(10),
  `education_id`  BIGINT NOT NULL, 
  `income_id`  BIGINT NOT NULL,
  `health_insurance_ind` VARCHAR(1) DEFAULT 'N',
  `read_news_ind` VARCHAR(1) DEFAULT 'N',
  `covid_test_ind` VARCHAR(1) DEFAULT 'N',
  `high_risk_ind` VARCHAR(1) DEFAULT 'N',
  `problem_id` BIGINT,
  `hosp_visit_ind` VARCHAR(1) DEFAULT 'N',
  `adeq_care_ind` VARCHAR(1) DEFAULT 'N',
  `overwh_hosp_ind` VARCHAR(1) DEFAULT 'N',
  PRIMARY KEY (`survey_id`),
  CONSTRAINT `svy_ctyzip_fk`
  FOREIGN KEY (`ctyzip_id`)
  REFERENCES `final_project_covid_norm`.`county_zip` (`ctyzip_id`),
  CONSTRAINT `svy_age_grp_fk`
  FOREIGN KEY (`age_grp_id`)
  REFERENCES `final_project_covid_norm`.`age_group` (`age_grp_id`),
  CONSTRAINT `svy_race_fk`
  FOREIGN KEY (`race_id`)
  REFERENCES `final_project_covid_norm`.`race` (`race_id`),
  CONSTRAINT `svy_education_fk`
  FOREIGN KEY (`education_id`)
  REFERENCES `final_project_covid_norm`.`education` (`education_id`),
  CONSTRAINT `svy_income_fk`
  FOREIGN KEY (`income_id`)
  REFERENCES `final_project_covid_norm`.`income` (`income_id`),
  CONSTRAINT `svy_problem_fk`
  FOREIGN KEY (`problem_id`)
  REFERENCES `final_project_covid_norm`.`problem` (`problem_id`)
   ) ENGINE = InnoDB
AUTO_INCREMENT = 1101
DEFAULT CHARACTER SET = latin1;

##########################################
###              DML                  ####
##########################################
TRUNCATE TABLE final_project_covid_norm.survey;
INSERT INTO final_project_covid_norm.survey (survey_id,ctyzip_id,age_grp_id,race_id,gender,education_id,income_id,health_insurance_ind,read_news_ind,covid_test_ind,high_risk_ind,problem_id,hosp_visit_ind,adeq_care_ind,overwh_hosp_ind) 
SELECT DISTINCT
      svy.survey_id,
      cz.ctyzip_id AS ctyzip_id,
      CASE WHEN ag.age_grp_yr IS NULL THEN 5 ELSE ag.age_grp_id END AS age_grp_id,
      rc.race_id    AS race_id,
      svy.gender,
      ed.education_id,
      inc.income_id,
      CASE WHEN TRIM(UPPER(health_insurance))  = 'YES' THEN 'Y' ELSE 'N' END AS health_insurance_ind,
	  CASE WHEN TRIM(UPPER(print))  = 'YES' THEN 'Y' ELSE 'N' END AS read_news_ind,
      CASE WHEN TRIM(UPPER(tested))  = 'YES' THEN 'Y' ELSE 'N' END AS covid_test_ind,
      CASE WHEN TRIM(UPPER(ongoing_higher_risk))  = 'YES' THEN 'Y' ELSE 'N' END AS high_risk_ind,
      prb.problem_id,
      CASE WHEN TRIM(UPPER(hospital_visit))  = 'YES' THEN 'Y' ELSE 'N' END AS hosp_visit_ind,
      CASE WHEN TRIM(UPPER(adequate_care))  = 'YES' THEN 'Y' ELSE 'N' END AS adeq_care_ind,
      CASE WHEN TRIM(UPPER(hospital_visit))  = 'YES' THEN 'Y' ELSE 'N' END AS overwh_hosp_ind
  FROM covid.survey svy
  LEFT JOIN final_project_covid_norm.county_zip cz
         ON CASE WHEN svy.zip_code = '69543' THEN '60543' WHEN svy.zip_code = '38143' THEN '38134' ELSE svy.zip_code END  = cz.zip 
  LEFT JOIN final_project_covid_norm.age_group ag
         ON svy.age_group = ag.age_grp_yr 
  LEFT JOIN final_project_covid_norm.race rc
         ON rc.race_nm =  CASE WHEN svy.race = 'American Indian or Alaska Native' THEN 'American Indian' WHEN svy.race = 'Native Hawaiian or Pacific Islander' THEN 'Native Hawaiian' ELSE  svy.race END 
  LEFT JOIN final_project_covid_norm.education ed
         ON svy.education_level = ed.education_level
  LEFT JOIN final_project_covid_norm.income inc
         ON svy.income_bracket = inc.income_bracket
  LEFT JOIN final_project_covid_norm.problem prb
         ON svy.serious_problem = prb.problem_type
;

######################################
### Table 12: Survey - news sources Table 
### Fetch news sources read by each survey respondent
######################################
##########################################
###              DDL                  ####
##########################################
DROP TABLE IF EXISTS final_project_covid_norm.survey_news;
CREATE TABLE final_project_covid_norm.survey_news (
  `survey_id` BIGINT NOT NULL,
  `news_id` BIGINT NOT NULL,
  CONSTRAINT `svy_news_surveyid_fk`
  FOREIGN KEY (`survey_id`)
  REFERENCES `final_project_covid_norm`.`survey` (`survey_id`),
  CONSTRAINT `svy_news_newsid_fk`
  FOREIGN KEY (`news_id`)
  REFERENCES `final_project_covid_norm`.`news_source` (`news_id`)
) ENGINE = InnoDB
AUTO_INCREMENT = 801
DEFAULT CHARACTER SET = utf8
;
##########################################
###              DML                  ####
##########################################
TRUNCATE TABLE final_project_covid_norm.survey_news;
INSERT INTO final_project_covid_norm.survey_news (survey_id,news_id) 
SELECT DISTINCT
       svy.survey_id,ns.news_id
FROM
    (SELECT DISTINCT survey_id,
           TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(survey.news_source, ',', numbers.num), ',', -1)) AS news_src_name
       FROM (SELECT 1 AS num UNION ALL SELECT 2 UNION ALL SELECT 3 
                             UNION ALL SELECT 4 UNION ALL SELECT 5 
                             UNION ALL SELECT 6 UNION ALL SELECT 7
             ) numbers 
	  INNER JOIN covid.survey
              ON CHAR_LENGTH(survey.news_source) -CHAR_LENGTH(REPLACE(survey.news_source, ',', ''))>=numbers.num-1
           WHERE TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(survey.news_source, ',', numbers.num), ',', -1)) <> ''
           ORDER BY num
    ) svy
INNER JOIN final_project_covid_norm.news_source ns
        ON ns.news_src_name = svy.news_src_name
 ;

######################################
### Table 13 : Nursing Table 
### Nursing home information from nursing dataset
######################################
##########################################
###              DDL                  ####
##########################################
DROP TABLE IF EXISTS final_project_covid_norm.nursing;
CREATE TABLE final_project_covid_norm.nursing (
  `nursing_id` BIGINT NOT NULL AUTO_INCREMENT,
  `nursing_facility` VARCHAR(150) NOT NULL,
  `address_id` BIGINT NOT NULL ,
  `cases` INT,
  `deaths` INT,
  `facility_rating` INT , 
  PRIMARY KEY (`nursing_id`),
  CONSTRAINT `nurs_address_id_fk`
  FOREIGN KEY (`address_id`)
   REFERENCES `final_project_covid_norm`.`address` (`address_id`)
) ENGINE = InnoDB
AUTO_INCREMENT = 1201
DEFAULT CHARACTER SET = latin1;

##########################################
###              DML                  ####
##########################################
TRUNCATE TABLE final_project_covid_norm.nursing;
INSERT INTO final_project_covid_norm.nursing (nursing_facility,address_id,cases,deaths,facility_rating)
SELECT DISTINCT
       facility AS nursing_facility,
       addr.address_id,
       cases,
       deaths,
       CASE WHEN TRIM(rating) IN ('','NEW') THEN NULL ELSE rating END  AS facility_rating
FROM covid.nursing nrs
LEFT JOIN final_project_covid_norm.address addr
        ON nrs.address = addr.address_ln_1
LEFT JOIN final_project_covid_norm.county_zip cz
        ON nrs.zip_code = cz.zip
WHERE TRIM(facility) <> ''
;

#############################################
### Table 14 : COVID Medicare archive Table 
##############################################
##########################################
###              DDL                  ####
##########################################
DROP TABLE IF EXISTS final_project_covid_norm.covid_medical_info;
CREATE TABLE final_project_covid_norm.covid_medical_info (
     `med_id` BIGINT NOT NULL AUTO_INCREMENT,
     `case_number` VARCHAR(20) NOT NULL,
     `date_of_death` DATE NOT NULL,
     `age` INT NOT NULL,
     `age_grp_id` BIGINT NOT NULL,
     `gender` VARCHAR(10) ,
     `race_id` BIGINT NOT NULL,
     `ctyzip_id` BIGINT NOT NULL,
     `Manner_of_death` VARCHAR(30),
     `nursing_home_ind` VARCHAR(1),
     `nursing_id` BIGINT ,
     `incident_address_id` BIGINT ,
  PRIMARY KEY (`med_id`),
    CONSTRAINT `med_ctyzip_fk`
  FOREIGN KEY (`ctyzip_id`)
  REFERENCES `final_project_covid_norm`.`county_zip` (`ctyzip_id`),
  CONSTRAINT `med_age_grp_fk`
  FOREIGN KEY (`age_grp_id`)
  REFERENCES `final_project_covid_norm`.`age_group` (`age_grp_id`),
  CONSTRAINT `med_race_fk`
  FOREIGN KEY (`race_id`)
  REFERENCES `final_project_covid_norm`.`race` (`race_id`),
  CONSTRAINT `med_address_id_fk`
  FOREIGN KEY (`incident_address_id`)
   REFERENCES `final_project_covid_norm`.`address` (`address_id`)
) ENGINE = InnoDB
AUTO_INCREMENT = 1301
DEFAULT CHARACTER SET = latin1;

CREATE INDEX `casenumber_idx` ON `final_project_covid_norm`.`covid_medical_info` (`case_number` ASC);

##########################################
###              DML                  ####
##########################################
TRUNCATE TABLE final_project_covid_norm.covid_medical_info;
INSERT INTO final_project_covid_norm.covid_medical_info (case_number,date_of_death,age,age_grp_id,gender,race_id,ctyzip_id,Manner_of_death,nursing_home_ind,nursing_id,incident_address_id)
SELECT 
     case_number,
     STR_TO_DATE(REPLACE(SUBSTRING_INDEX(Date_of_death,' ',1),'/',','),'%m,%d,%Y') as date_of_death,
     cov.age,
     ag.age_grp_id,
     cov.gender,
     rc.race_id,
     cz.ctyzip_id AS residence_ctyzip_id,
     Manner_of_death,
     CASE WHEN TRIM(Nursing_home) = 'TRUE' THEN 'Y' ELSE 'N' END nursing_home_ind,
     nur.nursing_id,
     addr.address_id as incident_address_id
    FROM covid.covid cov
  INNER JOIN final_project_covid_norm.age_group ag
    ON  ag.age_grp_nbr = ( CASE WHEN cov.age between 5 and 25 THEN '5-25' WHEN cov.age between 26 and 40 THEN '26-40'  
             WHEN cov.age between 41 and 55 THEN '41-55' WHEN cov.age between 56 and 76 THEN '56-76'  WHEN cov.age > 76 THEN 'OVER 77' END ) 
  LEFT JOIN final_project_covid_norm.race rc
     ON rc.race_nm = ( CASE WHEN cov.LATINX = 'TRUE' THEN 'LATINX' WHEN cov.race = 'Am. Indian' THEN 'American Indian' WHEN TRIM(cov.race) IN ('UNKNOWN','') THEN 'Other' ELSE cov.race END ) 
  LEFT JOIN final_project_covid_norm.county_zip cz
     ON cz.zip = cov.residence_zip
  LEFT JOIN final_project_covid_norm.nursing nur
     ON TRIM(cov.nursing_home_name) = TRIM(nur.nursing_facility)
  LEFT JOIN final_project_covid_norm.address addr
     ON cov.incident_address = addr.address_ln_1
WHERE  STR_TO_DATE(REPLACE(SUBSTRING_INDEX(cov.Date_of_Incident,' ',1),'/',','),'%m,%d,%Y')  > '2020-01-01'
  ;
 
######################################
### Table 15 : Cook County census_staging Table 
### Load census raw data to staging table
######################################
##########################################
###              DDL                  ####
##########################################
DROP TABLE IF EXISTS final_project_covid_norm.census_staging;
CREATE TABLE final_project_covid_norm.census_staging (
     `residence_zip` VARCHAR(40),
     `residence_Population` VARCHAR(40),
     `residence_median_income` VARCHAR(40),
     `residence_white` VARCHAR(40),
     `residence_black` VARCHAR(40),
     `residence_latinx` VARCHAR(40),
	 `residence_native` VARCHAR(40),
     `residence_asian` VARCHAR(40),
     `residence_hawaiian_PI` VARCHAR(40),
     `residence_other` VARCHAR(40),
     `residence_two_more` VARCHAR(40)
) ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1
;

LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\COVID_DATA_Demographics1.csv' 
INTO TABLE final_project_covid_norm.census_staging
FIELDS TERMINATED BY ',' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(residence_zip,residence_population,residence_median_income,residence_white,residence_black,residence_latinx,residence_native,residence_asian,residence_hawaiian_pi,residence_other,residence_two_more)
;

######################################
### Table 15 : Cook County census Table 
######################################
##########################################
###              DDL                  ####
##########################################
DROP TABLE IF EXISTS final_project_covid_norm.census;
CREATE TABLE final_project_covid_norm.census (
     `census_id` BIGINT NOT NULL AUTO_INCREMENT,
     `ctyzip_id` BIGINT NOT NULL,
     `race_id` BIGINT NOT NULL,
     `median_income` BIGINT,
     `population_count` BIGINT,
  PRIMARY KEY (`census_id`),
  CONSTRAINT `census_ctyzip_fk`
  FOREIGN KEY (`ctyzip_id`)
  REFERENCES `final_project_covid_norm`.`county_zip` (`ctyzip_id`),
  CONSTRAINT `census_race_fk`
  FOREIGN KEY (`race_id`)
  REFERENCES `final_project_covid_norm`.`race` (`race_id`)
) ENGINE = InnoDB
AUTO_INCREMENT = 1401
DEFAULT CHARACTER SET = latin1;

##########################################
###              DML                  ####
##########################################
TRUNCATE TABLE final_project_covid_norm.census;
INSERT IGNORE INTO final_project_covid_norm.census (ctyzip_id,race_id,median_income,population_count)
SELECT DISTINCT 
   cz.ctyzip_id,
   rc.race_id,
   residence_median_income AS median_income,
   cov.population_count as population_count
   FROM 
   ( SELECT REGEXP_REPLACE(residence_zip, "[^0-9]", "") AS residence_zip, 
            TRIM(residence_population) AS residence_population, 
            TRIM(residence_median_income) AS residence_median_income,
            CAST(population_count AS UNSIGNED) as population_count,
            TRIM(race) AS race,
            ROW_NUMBER() OVER (PARTITION BY residence_zip,race ORDER BY population_count DESC, residence_median_income DESC) cenrank
	   FROM  (
			SELECT residence_zip, residence_population, residence_median_income, Residence_White as population_count,'White' AS race FROM final_project_covid_norm.census_staging
			 UNION  
			SELECT residence_zip, residence_population, residence_median_income, Residence_Black as population_count,'Black' AS race FROM final_project_covid_norm.census_staging
			 UNION  
			SELECT residence_zip, residence_population, residence_median_income, Residence_latinx as population_count,'Latinx' AS race FROM final_project_covid_norm.census_staging
			 UNION  
			SELECT residence_zip, residence_population, residence_median_income, Residence_Asian as population_count,'Asian' AS race FROM final_project_covid_norm.census_staging
			 UNION  
			SELECT residence_zip, residence_population, residence_median_income, Residence_native as population_count,'American Indian' AS race FROM final_project_covid_norm.census_staging
			 UNION  
			SELECT residence_zip, residence_population, residence_median_income, Residence_hawaiian_PI as population_count,'Native Hawaiian' AS race FROM final_project_covid_norm.census_staging
			 UNION  
			SELECT residence_zip, residence_population, residence_median_income, Residence_Other as population_count,'Other' AS race FROM final_project_covid_norm.census_staging
			) inn 
        WHERE residence_population NOT in ('PO Box','Unique')
     ) cov
LEFT JOIN final_project_covid_norm.county_zip cz
     ON cz.zip = cov.residence_zip
LEFT JOIN final_project_covid_norm.race rc 
     ON rc.race_nm = cov.race
WHERE cov.cenrank = 1 
;
######################################
### Table 16 : Covid cases Table 
######################################
##########################################
###              DDL                  ####
##########################################
DROP TABLE IF EXISTS final_project_covid_norm.covid_cases;
CREATE TABLE final_project_covid_norm.covid_cases (
     `covcase_id` BIGINT NOT NULL AUTO_INCREMENT,
     `ctyzip_id` BIGINT NOT NULL,
     `total_cases` INT ,
     `total_tested` INT ,
     `nursing_home_cases` INT ,
     `nursing_home_deaths` INT,
  PRIMARY KEY (`covcase_id`),
    CONSTRAINT `covcase_ctyzip_fk`
  FOREIGN KEY (`ctyzip_id`)
  REFERENCES `final_project_covid_norm`.`county_zip` (`ctyzip_id`)
) ENGINE = InnoDB
AUTO_INCREMENT = 1501
DEFAULT CHARACTER SET = latin1;

##########################################
###              DML                  ####
##########################################
TRUNCATE TABLE final_project_covid_norm.covid_cases;
INSERT INTO  final_project_covid_norm.covid_cases (ctyzip_id,total_cases,total_tested,nursing_home_cases,nursing_home_deaths)
SELECT  DISTINCT
       slt.ctyzip_id,
       slt.total_cases,
       slt.total_tested,
       slt.nursing_home_cases,
       slt.nursing_home_deaths
FROM
( SELECT
       cz.ctyzip_id,
       confirmed_cases AS total_cases,
       total_tested   AS total_tested,
       nursing_home_confirmed_cases as nursing_home_cases,
       nursing_home_deaths as nursing_home_deaths
       ,row_number() OVER (PARTITION BY cz.ctyzip_id ORDER BY nursing_home_confirmed_cases DESC,nursing_home_deaths DESC) nurrank
 FROM covid.covid cov
 LEFT JOIN final_project_covid_norm.county_zip cz
      ON cz.zip = cov.incident_zip_code
 WHERE TRIM(cov.incident_address) <> ''
 ) slt 
 WHERE slt.nurrank = 1
 ;
  
 ######################################
### Table 16A: social_behavior_staging
######################################
####
####Load the CSV file to the staging layer
####

DROP TABLE IF EXISTS final_project_covid_norm.social_behavior_staging;
CREATE TABLE final_project_covid_norm.social_behavior_staging (
`zipcode` VARCHAR(9) NOT NULL,
`behv_date` VARCHAR(10) NOT NULL,
`device_count` VARCHAR(25) ,
`distance_traveled_from_home` VARCHAR(25) ,
`completely_home_device_count` VARCHAR(25) ,
`median_home_dwell_time` VARCHAR(25) ,
`part_time_work_behavior_devices` VARCHAR(25) ,
`full_time_work_behavior_devices` VARCHAR(25) ,
`delivery_behavior_devices` VARCHAR(25) ,
`median_non_home_dwell_time` VARCHAR(25) ,
`candidate_device_count` VARCHAR(25) ,
`median_percentage_time_home` VARCHAR(25) ,
`at_home_during_hour0` VARCHAR(25) ,
`at_home_during_hour1` VARCHAR(25) ,
`at_home_during_hour2` VARCHAR(25) ,
`at_home_during_hour3` VARCHAR(25) ,
`at_home_during_hour4` VARCHAR(25) ,
`at_home_during_hour5` VARCHAR(25) ,
`at_home_during_hour6` VARCHAR(25) ,
`at_home_during_hour7` VARCHAR(25) ,
`at_home_during_hour8` VARCHAR(25) ,
`at_home_during_hour9` VARCHAR(25) ,
`at_home_during_hour10` VARCHAR(25) ,
`at_home_during_hour11` VARCHAR(25) ,
`at_home_during_hour12` VARCHAR(25) ,
`at_home_during_hour13` VARCHAR(25) ,
`at_home_during_hour14` VARCHAR(25) ,
`at_home_during_hour15` VARCHAR(25) ,
`at_home_during_hour16` VARCHAR(25) ,
`at_home_during_hour17` VARCHAR(25) ,
`at_home_during_hour18` VARCHAR(25) ,
`at_home_during_hour19` VARCHAR(25) ,
`at_home_during_hour20` VARCHAR(25) ,
`at_home_during_hour21` VARCHAR(25) ,
`at_home_during_hour22` VARCHAR(25) ,
`at_home_during_hour23` VARCHAR(25) 
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

SHOW VARIABLES LIKE "secure_file_priv";

LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\Social_distancing_data_Cook_febr_april.csv' 
INTO TABLE final_project_covid_norm.social_behavior_staging
FIELDS TERMINATED BY ',' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(zipcode,behv_date,device_count,distance_traveled_from_home,completely_home_device_count,median_home_dwell_time,part_time_work_behavior_devices,full_time_work_behavior_devices,delivery_behavior_devices,median_non_home_dwell_time,candidate_device_count,median_percentage_time_home,at_home_during_hour0,at_home_during_hour1,at_home_during_hour2,at_home_during_hour3,at_home_during_hour4,at_home_during_hour5,at_home_during_hour6,at_home_during_hour7,at_home_during_hour8,at_home_during_hour9,at_home_during_hour10,at_home_during_hour11,at_home_during_hour12,at_home_during_hour13,at_home_during_hour14,at_home_during_hour15,at_home_during_hour16,at_home_during_hour17,at_home_during_hour18,at_home_during_hour19,at_home_during_hour20,at_home_during_hour21,at_home_during_hour22,at_home_during_hour23)
;

#########################################################
#### Table 16B: Social behavior Denormalized- Load from staging table
##########################################################

DROP TABLE IF EXISTS final_project_covid_norm.social_behavior_denorm; 
CREATE TABLE final_project_covid_norm.social_behavior_denorm AS
SELECT DISTINCT 
         cz.ctyzip_id
		,STR_TO_DATE(behv_date,'%Y-%m-%d') as behv_date
        ,device_count AS device_count
        ,(CASE WHEN distance_traveled_from_home = 'nan' THEN 0 ELSE distance_traveled_from_home END ) AS distance_traveled
        ,completely_home_device_count AS home_device_count
        ,median_home_dwell_time AS median_home_dwell_time
        ,part_time_work_behavior_devices AS part_time_work_behavior_devices
        ,full_time_work_behavior_devices AS full_time_work_behavior_devices
        ,delivery_behavior_devices AS delivery_behavior_devices
        ,median_non_home_dwell_time AS median_non_home_dwell_time
        ,candidate_device_count AS candidate_device_count
        ,median_percentage_time_home AS median_percentage_time_home
        ,at_home_during_hour0 AS at_home_during_hour0
        ,at_home_during_hour1 AS at_home_during_hour1
        ,at_home_during_hour2 AS at_home_during_hour2
        ,at_home_during_hour3 AS at_home_during_hour3
        ,at_home_during_hour4 AS at_home_during_hour4
        ,at_home_during_hour5 AS at_home_during_hour5
        ,at_home_during_hour6 AS at_home_during_hour6
        ,at_home_during_hour7 AS at_home_during_hour7
        ,at_home_during_hour8 AS at_home_during_hour8
        ,at_home_during_hour9 AS at_home_during_hour9
        ,at_home_during_hour10 AS at_home_during_hour10
        ,at_home_during_hour11 AS at_home_during_hour11
        ,at_home_during_hour12 AS at_home_during_hour12
        ,at_home_during_hour13 AS at_home_during_hour13
        ,at_home_during_hour14 AS at_home_during_hour14
        ,at_home_during_hour15 AS at_home_during_hour15
        ,at_home_during_hour16 AS at_home_during_hour16
        ,at_home_during_hour17 AS at_home_during_hour17
        ,at_home_during_hour18 AS at_home_during_hour18
        ,at_home_during_hour19 AS at_home_during_hour19
        ,at_home_during_hour20 AS at_home_during_hour20
        ,at_home_during_hour21 AS at_home_during_hour21
        ,at_home_during_hour22 AS at_home_during_hour22
        ,at_home_during_hour23 AS at_home_during_hour23
      FROM final_project_covid_norm.social_behavior_staging bstg
 INNER JOIN final_project_covid_norm.county_zip cz
      ON cz.zip = bstg.zipcode
;

#############################################################################
#### Table 16B: Social behavior  and Social_athome Tables
####  Normalize by hour and load from denorm table
#############################################################################
#############
######DDL####
#############
DROP TABLE IF EXISTS final_project_covid_norm.social_behavior;
CREATE TABLE final_project_covid_norm.social_behavior (
`socialbehv_id` BIGINT NOT NULL AUTO_INCREMENT,
`ctyzip_id` BIGINT NOT NULL,
`behv_date` DATE NOT NULL,
`device_count` BIGINT NOT NULL DEFAULT 0,
`distance_traveled` BIGINT NOT NULL DEFAULT 0,
`home_device_count` BIGINT NOT NULL DEFAULT 0,
`median_home_dwell_time` BIGINT NOT NULL DEFAULT 0,
`part_time_work_behavior_devices` BIGINT NOT NULL DEFAULT 0,
`full_time_work_behavior_devices` BIGINT NOT NULL DEFAULT 0,
`delivery_behavior_devices` BIGINT NOT NULL DEFAULT 0,
`median_non_home_dwell_time` BIGINT NOT NULL DEFAULT 0,
`candidate_device_count` BIGINT NOT NULL DEFAULT 0,
`median_percentage_time_home` BIGINT NOT NULL DEFAULT 0,
  PRIMARY KEY (`socialbehv_id`),
  CONSTRAINT `socialbehv_ctyzip_fk`
  FOREIGN KEY (`ctyzip_id`)
  REFERENCES `final_project_covid_norm`.`county_zip` (`ctyzip_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8
;

#############
######DML####
#############
TRUNCATE TABLE final_project_covid_norm.social_behavior; 
INSERT INTO final_project_covid_norm.social_behavior (ctyzip_id,behv_date,device_count,distance_traveled,home_device_count,median_home_dwell_time,part_time_work_behavior_devices,full_time_work_behavior_devices,delivery_behavior_devices,median_non_home_dwell_time,candidate_device_count,median_percentage_time_home)
SELECT DISTINCT 
	   bdnrm.ctyzip_id
	  ,bdnrm.behv_date
      ,device_count AS device_count
      ,distance_traveled
      ,home_device_count AS home_device_count
      ,median_home_dwell_time AS median_home_dwell_time
      ,part_time_work_behavior_devices AS part_time_work_behavior_devices
      ,full_time_work_behavior_devices AS full_time_work_behavior_devices
      ,delivery_behavior_devices AS delivery_behavior_devices
      ,median_non_home_dwell_time AS median_non_home_dwell_time
      ,candidate_device_count AS candidate_device_count
      ,median_percentage_time_home AS median_percentage_time_home
      FROM final_project_covid_norm.social_behavior_denorm bdnrm
;


DROP TABLE IF EXISTS final_project_covid_norm.social_athome;
CREATE TABLE final_project_covid_norm.social_athome (
`athome_id` BIGINT NOT NULL AUTO_INCREMENT,
`socialbehv_id` BIGINT NOT NULL,
`hour_val` INT NOT NULL,
`athome_count` BIGINT NOT NULL DEFAULT 0,
  PRIMARY KEY (`athome_id`),
  CONSTRAINT `socialbehv_id_fk`
  FOREIGN KEY (`socialbehv_id`)
  REFERENCES `final_project_covid_norm`.`social_behavior` (`socialbehv_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8
;

TRUNCATE TABLE final_project_covid_norm.social_athome; 
INSERT INTO final_project_covid_norm.social_athome (socialbehv_id,hour_val,athome_count)
SELECT DISTINCT 
       bdnrm.socialbehv_id
	  ,athome.hour_val
      ,athome.at_home_count
  FROM final_project_covid_norm.social_behavior bdnrm
  LEFT JOIN (SELECT ctyzip_id,behv_date, 0 AS hour_val,at_home_during_hour0 AS at_home_count FROM final_project_covid_norm.social_behavior_denorm
         UNION 
        SELECT ctyzip_id,behv_date, 1 AS hour_val,at_home_during_hour1 AS at_home_count FROM final_project_covid_norm.social_behavior_denorm
         UNION
		SELECT ctyzip_id,behv_date, 2 AS hour_val,at_home_during_hour2 AS at_home_count FROM final_project_covid_norm.social_behavior_denorm
         UNION 
        SELECT ctyzip_id,behv_date, 3 AS hour_val,at_home_during_hour3 AS at_home_count FROM final_project_covid_norm.social_behavior_denorm
         UNION
        SELECT ctyzip_id,behv_date, 4 AS hour_val,at_home_during_hour4 AS at_home_count FROM final_project_covid_norm.social_behavior_denorm
         UNION
		SELECT ctyzip_id,behv_date, 5 AS hour_val,at_home_during_hour5 AS at_home_count FROM final_project_covid_norm.social_behavior_denorm
         UNION 
        SELECT ctyzip_id,behv_date, 6 AS hour_val,at_home_during_hour6 AS at_home_count FROM final_project_covid_norm.social_behavior_denorm
         UNION 
        SELECT ctyzip_id,behv_date, 7 AS hour_val,at_home_during_hour7 AS at_home_count FROM final_project_covid_norm.social_behavior_denorm
         UNION
		SELECT ctyzip_id,behv_date, 8 AS hour_val,at_home_during_hour8 AS at_home_count FROM final_project_covid_norm.social_behavior_denorm
         UNION 
        SELECT ctyzip_id,behv_date, 9 AS hour_val,at_home_during_hour9 AS at_home_count FROM final_project_covid_norm.social_behavior_denorm
         UNION
        SELECT ctyzip_id,behv_date, 10 AS hour_val,at_home_during_hour10 AS at_home_count FROM final_project_covid_norm.social_behavior_denorm
         UNION
		SELECT ctyzip_id,behv_date, 11 AS hour_val,at_home_during_hour11 AS at_home_count FROM final_project_covid_norm.social_behavior_denorm
         UNION 
        SELECT ctyzip_id,behv_date, 12 AS hour_val,at_home_during_hour12 AS at_home_count FROM final_project_covid_norm.social_behavior_denorm
         UNION 
        SELECT ctyzip_id,behv_date, 13 AS hour_val,at_home_during_hour13 AS at_home_count FROM final_project_covid_norm.social_behavior_denorm
         UNION
		SELECT ctyzip_id,behv_date, 14 AS hour_val,at_home_during_hour14 AS at_home_count FROM final_project_covid_norm.social_behavior_denorm
         UNION 
        SELECT ctyzip_id,behv_date, 15 AS hour_val,at_home_during_hour15 AS at_home_count FROM final_project_covid_norm.social_behavior_denorm
         UNION
        SELECT ctyzip_id,behv_date, 16 AS hour_val,at_home_during_hour16 AS at_home_count FROM final_project_covid_norm.social_behavior_denorm
         UNION
		SELECT ctyzip_id,behv_date, 17 AS hour_val,at_home_during_hour17 AS at_home_count FROM final_project_covid_norm.social_behavior_denorm
         UNION 
        SELECT ctyzip_id,behv_date, 18 AS hour_val,at_home_during_hour18 AS at_home_count FROM final_project_covid_norm.social_behavior_denorm
         UNION 
        SELECT ctyzip_id,behv_date, 19 AS hour_val,at_home_during_hour19 AS at_home_count FROM final_project_covid_norm.social_behavior_denorm
         UNION
		SELECT ctyzip_id,behv_date, 20 AS hour_val,at_home_during_hour20 AS at_home_count FROM final_project_covid_norm.social_behavior_denorm
         UNION 
        SELECT ctyzip_id,behv_date, 21 AS hour_val,at_home_during_hour21 AS at_home_count FROM final_project_covid_norm.social_behavior_denorm
         UNION
        SELECT ctyzip_id,behv_date, 22 AS hour_val,at_home_during_hour22 AS at_home_count FROM final_project_covid_norm.social_behavior_denorm
         UNION
		SELECT ctyzip_id,behv_date, 23 AS hour_val,at_home_during_hour23 AS at_home_count FROM final_project_covid_norm.social_behavior_denorm
         ) athome
ON  bdnrm.ctyzip_id = athome.ctyzip_id
AND bdnrm.behv_date = athome.behv_date 
;


##########################################
##Table 2 case_symptoms
##########################################
#############
######DDL####
#############
DROP TABLE IF EXISTS final_project_covid_norm.case_symptoms;
CREATE TABLE final_project_covid_norm.case_symptoms (
  `med_id` BIGINT NOT NULL AUTO_INCREMENT,
  `symptom_id` BIGINT,
  `prim_cause_ind` VARCHAR(1) NOT NULL,
  CONSTRAINT `med_id_fk`
    FOREIGN KEY (`med_id`)
    REFERENCES `final_project_covid_norm`.`covid_medical_info` (`med_id`),
  CONSTRAINT `symptom_id_fk`
    FOREIGN KEY (`symptom_id`)
    REFERENCES `final_project_covid_norm`.`symptoms` (`symptom_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
) 
ENGINE = InnoDB
AUTO_INCREMENT = 201
DEFAULT CHARACTER SET = latin1;
;

#############
######DML####
#############

TRUNCATE TABLE final_project_covid_norm.case_symptoms;
INSERT INTO final_project_covid_norm.case_symptoms (med_id,symptom_id,prim_cause_ind)
SELECT mi.med_id,
       dc.symptom_id,
       cau.prim_cause_ind
FROM 
(
SELECT DISTINCT Case_Number,primary_cause AS cause_type,'Y' AS prim_cause_ind FROM covid.covid pc
UNION
SELECT DISTINCT Case_Number,primary_cause_line_A AS cause_type,'Y' AS prim_cause_ind FROM covid.covid pc
UNION
SELECT DISTINCT Case_Number,primary_cause_line_B AS cause_type,'Y' AS prim_cause_ind FROM covid.covid pc
UNION
SELECT DISTINCT Case_Number,primary_cause_line_C AS cause_type,'Y' AS prim_cause_ind FROM covid.covid pc
UNION
SELECT DISTINCT Case_Number,secondary_cause AS cause_type,'N' AS prim_cause_ind FROM covid.covid pc
) cau 
INNER JOIN final_project_covid_norm.covid_medical_info mi
        ON cau.Case_Number = mi.Case_Number
INNER JOIN final_project_covid_norm.symptoms dc
        ON cau.cause_type = dc.symptom_type
ORDER BY mi.med_id
;
/*
TRUNCATE TABLE final_project_covid_norm.case_symptoms;
INSERT INTO final_project_covid_norm.case_symptoms (med_id,symptom_id,prim_cause_ind)
SELECT mi.med_id,
       dc.symptom_id,
       csym.prim_cause_ind
FROM
( SELECT DISTINCT Case_Number,symptom_type,prim_cause_ind
    FROM  ( 
       SELECT Case_Number,prim_cause_ind, 
              TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(cau1.symptom_type, ',', numbers.num), ',', -1)) AS symptom_type
         FROM ( SELECT 1 AS num UNION ALL SELECT 2
				UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7
			   ) numbers 
    INNER JOIN ( SELECT DISTINCT Case_Number,TRIM(primary_cause) AS symptom_type,'Y' AS prim_cause_ind FROM covid.covid pc
				 UNION
				 SELECT DISTINCT Case_Number,TRIM(primary_cause_line_A) AS symptom_type,'Y' AS prim_cause_ind FROM covid.covid pc
				 UNION
				 SELECT DISTINCT Case_Number,TRIM(primary_cause_line_B) AS symptom_type,'Y' AS prim_cause_ind FROM covid.covid pc
				 UNION	
				 SELECT DISTINCT Case_Number,TRIM(primary_cause_line_C) AS symptom_type,'Y' AS prim_cause_ind FROM covid.covid pc
				 UNION
				 SELECT DISTINCT Case_Number,TRIM(secondary_cause) AS symptom_type,'Y' AS prim_cause_ind FROM covid.covid pc
				 UNION
				 SELECT DISTINCT Case_Number,TRIM(secondary_cause) AS symptom_type,'N' AS prim_cause_ind FROM covid.covid pc
			   ) cau1 
			ON CHAR_LENGTH(cau1.symptom_type)-CHAR_LENGTH(REPLACE(cau1.symptom_type, ',', ''))>=numbers.num-1
		  WHERE TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(cau1.symptom_type, ',', numbers.num), ',', -1)) <> '' 
          ORDER BY num 
	  ) cau
WHERE COALESCE(TRIM(cau.symptom_type),'') NOT IN ('','.')
ORDER BY cau.symptom_type
) csym
INNER JOIN final_project_covid_norm.covid_medical_info mi
        ON csym.Case_Number = mi.case_Number
INNER JOIN final_project_covid_norm.symptoms dc
        ON csym.symptom_type = dc.symptom_type
;
*/


############################
#### DROP Staging tables
############################
DROP TABLE IF EXISTS final_project_covid_norm.social_behavior_staging;
DROP TABLE IF EXISTS final_project_covid_norm.county_zip_staging;
DROP TABLE IF EXISTS final_project_covid_norm.census_staging;



##DROP TABLE IF EXISTS final_project_covid_norm.social_behavior;
##CREATE TABLE final_project_covid_norm.social_behavior AS 
/*TRUNCATE TABLE final_project_covid_norm.social_behavior; 
INSERT INTO final_project_covid_norm.social_behavior  (ctyzip_id,behv_date,device_count,distance_traveled_from_home,completely_home_device_count,median_home_dwell_time,part_time_work_behavior_devices,full_time_work_behavior_devices,delivery_behavior_devices,median_non_home_dwell_time,candidate_device_count,median_percentage_time_home,at_home_during_hour0,at_home_during_hour1,at_home_during_hour2,at_home_during_hour3,at_home_during_hour4,at_home_during_hour5,at_home_during_hour6,at_home_during_hour7,at_home_during_hour8,at_home_during_hour9,at_home_during_hour10,at_home_during_hour11,at_home_during_hour12,at_home_during_hour13,at_home_during_hour14,at_home_during_hour15,at_home_during_hour16,at_home_during_hour17,at_home_during_hour18,at_home_during_hour19,at_home_during_hour20,at_home_during_hour21,at_home_during_hour22,at_home_during_hour23)
SELECT DISTINCT 
         cz.ctyzip_id
		,STR_TO_DATE(behv_date,'%Y-%m-%d') as behv_date
        ,CAST(device_count AS UNSIGNED) AS device_count
        ,CAST((CASE WHEN distance_traveled_from_home = 'nan' THEN 0 ELSE distance_traveled_from_home END ) AS UNSIGNED) AS distance_traveled
        ,CAST(completely_home_device_count AS UNSIGNED) AS home_device_count
        ,CAST(median_home_dwell_time AS UNSIGNED) AS median_home_dwell_time
        ,CAST(part_time_work_behavior_devices AS UNSIGNED) AS part_time_work_behavior_devices
        ,CAST(full_time_work_behavior_devices AS UNSIGNED) AS full_time_work_behavior_devices
        ,CAST(delivery_behavior_devices AS UNSIGNED) AS delivery_behavior_devices
        ,CAST(median_non_home_dwell_time AS UNSIGNED) AS median_non_home_dwell_time
        ,CAST(candidate_device_count AS UNSIGNED) AS candidate_device_count
        ,CAST(median_percentage_time_home AS UNSIGNED) AS median_percentage_time_home
        ,CAST(at_home_during_hour0 AS UNSIGNED) AS at_home_during_hour0
        ,CAST(at_home_during_hour1 AS UNSIGNED) AS at_home_during_hour1
        ,CAST(at_home_during_hour2 AS UNSIGNED) AS at_home_during_hour2
        ,CAST(at_home_during_hour3 AS UNSIGNED) AS at_home_during_hour3
        ,CAST(at_home_during_hour4 AS UNSIGNED) AS at_home_during_hour4
        ,CAST(at_home_during_hour5 AS UNSIGNED) AS at_home_during_hour5
        ,CAST(at_home_during_hour6 AS UNSIGNED) AS at_home_during_hour6
        ,CAST(at_home_during_hour7 AS UNSIGNED) AS at_home_during_hour7
        ,CAST(at_home_during_hour8 AS UNSIGNED) AS at_home_during_hour8
        ,CAST(at_home_during_hour9 AS UNSIGNED) AS at_home_during_hour9
        ,CAST(at_home_during_hour10 AS UNSIGNED) AS at_home_during_hour10
        ,CAST(at_home_during_hour11 AS UNSIGNED) AS at_home_during_hour11
        ,CAST(at_home_during_hour12 AS UNSIGNED) AS at_home_during_hour12
        ,CAST(at_home_during_hour13 AS UNSIGNED) AS at_home_during_hour13
        ,CAST(at_home_during_hour14 AS UNSIGNED) AS at_home_during_hour14
        ,CAST(at_home_during_hour15 AS UNSIGNED) AS at_home_during_hour15
        ,CAST(at_home_during_hour16 AS UNSIGNED) AS at_home_during_hour16
        ,CAST(at_home_during_hour17 AS UNSIGNED) AS at_home_during_hour17
        ,CAST(at_home_during_hour18 AS UNSIGNED) AS at_home_during_hour18
        ,CAST(at_home_during_hour19 AS UNSIGNED) AS at_home_during_hour19
        ,CAST(at_home_during_hour20 AS UNSIGNED) AS at_home_during_hour20
        ,CAST(at_home_during_hour21 AS UNSIGNED) AS at_home_during_hour21
        ,CAST(at_home_during_hour22 AS UNSIGNED) AS at_home_during_hour22
        ,CAST(at_home_during_hour23 AS UNSIGNED) AS at_home_during_hour23
      FROM final_project_covid_norm.social_behavior_staging bstg
 INNER JOIN final_project_covid_norm.county_zip cz
      ON cz.zip = bstg.zipcode
;*/