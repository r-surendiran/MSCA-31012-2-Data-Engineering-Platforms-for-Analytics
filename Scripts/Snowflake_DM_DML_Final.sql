/***********************************************
**                MSc ANALYTICS 
**     DATA ENGINEERING PLATFORMS (MSCA 31012-2)
** File:   Final Project Snowflake DML 
** Desc:   ETL/DML for the Final Project Snowflake Dimensional model
** Auth:   Team 1
** Date:   05/24/2020
** ALL RIGHTS RESERVED | DO NOT DISTRIBUTE
************************************************/

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL,ALLOW_INVALID_DATES';

USE `final_project_covid_dw`;

#################################################
## Dimension table 1 dim_age_grp              ###
#################################################
TRUNCATE TABLE final_project_covid_dw.dim_age_group;
INSERT INTO final_project_covid_dw.dim_age_group (    
   age_grp_id ,
   age_grp_yr ,
   age_grp_nbr,
   age_grp_gen
   )
   ( SELECT
   agp.age_grp_id ,
   agp.age_grp_yr ,
   agp.age_grp_nbr,
   agp.age_grp_gen FROM final_project_covid_norm.age_group agp ORDER BY agp.age_grp_id) ;

#################################################
## Dimension table 2 dim_race                 ###
#################################################
TRUNCATE TABLE final_project_covid_dw.dim_race;
INSERT INTO final_project_covid_dw.dim_race (    
   race_id ,
   race_name
   )
   ( SELECT
         race_id ,
         race_nm 
      FROM final_project_covid_norm.race ORDER BY race_id) ;
      
#################################################
## Dimension table 3 dim_location             ###
## Added covid cases , testing details,nursing home details to the dimension. The information extracted from covid cases table
#################################################
TRUNCATE TABLE final_project_covid_dw.dim_location;
INSERT INTO final_project_covid_dw.dim_location (ctyzip_id,zip, fips, city, state, cty_nm,total_cases,total_tested,nursing_home_cases,nursing_home_deaths)
   ( SELECT DISTINCT 
	      cz.ctyzip_id,
	      cz.zip, 
	      cz.fips, 
	      cz.city, 
	      cz.state, 
	      cz.cty_nm,
	      cc.total_cases,
          cc.total_tested,
          cc.nursing_home_cases,
          cc.nursing_home_deaths
      FROM final_project_covid_norm.county_zip cz
LEFT JOIN final_project_covid_norm.covid_cases cc
		ON cc.ctyzip_id = cz.ctyzip_id      
WHERE TRIM(UPPER(cty_nm)) LIKE '%COOK%' ORDER BY ctyzip_id) ;
      
/*#################################################
## Dimension table 3A dim_loc_cases           ###
#################################################
TRUNCATE TABLE final_project_covid_dw.dim_loc_cases;
INSERT INTO final_project_covid_dw.dim_loc_cases (case_key ,location_key,total_cases,total_tested,nursing_home_cases,nursing_home_deaths)
SELECT 
 cc.covcase_id AS case_key,
 dl.location_key,
 cc.total_cases,
 cc.total_tested,
 cc.nursing_home_cases,
 cc.nursing_home_deaths
FROM final_project_covid_norm.covid_cases cc
INNER JOIN final_project_covid_dw.dim_location dl
		ON cc.ctyzip_id = dl.ctyzip_id
;
*/

#################################################
## Dimension table 3B dim_loc_nursing         ###
#################################################
TRUNCATE TABLE final_project_covid_dw.dim_loc_nursing ;
INSERT INTO final_project_covid_dw.dim_loc_nursing (nursing_key ,location_key,facility_name,address_ln_1,address_ln_2,nursing_cases,nursing_deaths)
SELECT DISTINCT
 nr.nursing_id AS nursing_key,
 adz.location_key,
 nr.nursing_facility AS facility_name,
 adz.address_ln_1,
 adz.address_ln_2,
 nr.cases AS nursing_cases,
 nr.deaths AS nursing_deaths
FROM final_project_covid_norm.nursing nr
INNER JOIN (SELECT  DISTINCT ad.address_id,
                   ad.address_ln_1,
				   ad.address_ln_2,
                   dl.location_key
			 FROM final_project_covid_norm.address ad
			 INNER JOIN final_project_covid_dw.dim_location dl
		              ON ad.ctyzip_id = dl.ctyzip_id ) adz
		ON nr.address_id = adz.address_id
;

#################################################
## Dimension table 3C dim_survey              ###
#################################################
TRUNCATE TABLE final_project_covid_dw.dim_survey;
INSERT INTO final_project_covid_dw.dim_survey (survey_key,location_key,generation,ethnicity,gender,education_lvl,income_bracket,health_insurance,read_news,covid_test,high_risk,problem,hosp_visit,adeq_care,overwh_hosp)
SELECT DISTINCT
svy.survey_id AS survey_key,
dl.location_key,
ag.age_grp_gen AS generation,
rc.race_name AS ethnicity,
svy.gender,
ed.education_level AS education_lvl,
inc.income_bracket AS income_bracket,
CASE WHEN svy.health_insurance_ind ='Y' THEN 1 ELSE 0 END AS health_insurance,
CASE WHEN svy.read_news_ind ='Y' THEN 1 ELSE 0 END AS read_news ,
CASE WHEN svy.covid_test_ind ='Y' THEN 1 ELSE 0 END AS covid_test ,
CASE WHEN svy.high_risk_ind ='Y' THEN 1 ELSE 0 END AS high_risk,
pb.problem_type AS problem,
CASE WHEN svy.hosp_visit_ind ='Y' THEN 1 ELSE 0 END AS hosp_visit,
CASE WHEN svy.adeq_care_ind ='Y' THEN 1 ELSE 0 END AS adeq_care,
CASE WHEN svy.overwh_hosp_ind ='Y' THEN 1 ELSE 0 END AS overwh_hosp
FROM final_project_covid_norm.survey svy
INNER JOIN final_project_covid_dw.dim_location dl
        ON svy.ctyzip_id = dl.ctyzip_id 
LEFT JOIN final_project_covid_dw.dim_race rc
        ON svy.race_id = rc.race_id
LEFT JOIN final_project_covid_dw.dim_age_group ag
        ON svy.age_grp_id = ag.age_grp_id
LEFT JOIN final_project_covid_norm.education ed
        ON svy.education_id = ed.education_id
LEFT JOIN final_project_covid_norm.income inc
        ON svy.income_id = inc.income_id
LEFT JOIN final_project_covid_norm.problem pb
        ON svy.problem_id = pb.problem_id
;

#################################################
## Dimension table 4 dim_date                 ###
#################################################
TRUNCATE TABLE final_project_covid_dw.numbers_small;
INSERT INTO final_project_covid_dw.numbers_small VALUES (0),(1),(2),(3),(4),(5),(6),(7),(8),(9);
TRUNCATE TABLE final_project_covid_dw.numbers;
INSERT INTO final_project_covid_dw.numbers
SELECT 
    thousands.number * 1000 + hundreds.number * 100 + tens.number * 10 + ones.number
FROM
    numbers_small thousands,
    numbers_small hundreds,
    numbers_small tens,
    numbers_small ones
LIMIT 1000000;

TRUNCATE TABLE final_project_covid_dw.dim_date; 
INSERT INTO final_project_covid_dw.dim_date (date_Id, date_val)
SELECT 
    number,
    DATE_ADD('2019-12-01',
        INTERVAL number DAY)
FROM
    final_project_covid_dw.numbers
WHERE
    DATE_ADD('2019-12-01',
        INTERVAL number DAY) BETWEEN '2019-12-01' AND '2020-12-31'
ORDER BY number;

SET SQL_SAFE_UPDATES = 0;
UPDATE final_project_covid_dw.dim_date 
SET 
    timestamp = UNIX_TIMESTAMP(date_val),
    day_of_week = DATE_FORMAT(date_val, '%W'),
    weekend = IF(DATE_FORMAT(date_val, '%W') IN ('Saturday' , 'Sunday'),
        'Weekend',
        'Weekday'),
    month = DATE_FORMAT(date_val, '%M'),
    year = DATE_FORMAT(date_val, '%Y'),
    month_day = DATE_FORMAT(date_val, '%d')
;

#################################################
### FACTS Table 1  - Social Behavior
### Calculated Measure 1 - Total covid death per zip date from covid medical archive table
### Calculated Measure 2 - Total nursing home death  per zip,date from covid medical archive table
### Other measures are from social distancing behavior table
################################################
TRUNCATE TABLE final_project_covid_dw.facts_social_behavior;
INSERT INTO final_project_covid_dw.facts_social_behavior
SELECT 
         loc.location_key
		,dt.date_id AS behv_date_key
		,device_count
		,distance_traveled AS distance_traveled
        ,home_device_count AS home_device_count
        ,median_home_dwell_time AS median_home_dwell_time
        ,part_time_work_behavior_devices AS part_time_work_behavior_devices
        ,full_time_work_behavior_devices AS full_time_work_behavior_devices
        ,delivery_behavior_devices AS delivery_behavior_devices
        ,median_non_home_dwell_time AS median_non_home_dwell_time
        ,candidate_device_count AS candidate_device_count
        ,median_percentage_time_home AS median_percentage_time_home
        ,at_home_during_hour0 AS count_hour0
        ,at_home_during_hour1 AS count_hour1
        ,at_home_during_hour2 AS count_hour2
        ,at_home_during_hour3 AS count_hour3
        ,at_home_during_hour4 AS count_hour4
        ,at_home_during_hour5 AS count_hour5
        ,at_home_during_hour6 AS count_hour6
        ,at_home_during_hour7 AS count_hour7
        ,at_home_during_hour8 AS count_hour8
        ,at_home_during_hour9 AS count_hour9
        ,at_home_during_hour10 AS count_hour10
        ,at_home_during_hour11 AS count_hour11
        ,at_home_during_hour12 AS count_hour12
        ,at_home_during_hour13 AS count_hour13
        ,at_home_during_hour14 AS count_hour14
        ,at_home_during_hour15 AS count_hour15
        ,at_home_during_hour16 AS count_hour16
        ,at_home_during_hour17 AS count_hour17
        ,at_home_during_hour18 AS count_hour18
        ,at_home_during_hour19 AS count_hour19
        ,at_home_during_hour20 AS count_hour20
        ,at_home_during_hour21 AS count_hour21
        ,at_home_during_hour22 AS count_hour22
        ,at_home_during_hour23 AS count_hour23
        ,cmi.total_covid_deaths
        ,cmi.total_nursing_deaths
FROM  final_project_covid_norm.social_behavior_denorm sb
LEFT JOIN final_project_covid_dw.dim_location loc
       ON sb.ctyzip_id = loc.ctyzip_id
LEFT JOIN final_project_covid_dw.dim_date dt
       ON CAST(sb.behv_date AS DATE) = CAST(dt.date_val AS DATE)
LEFT JOIN ( SELECT  date_of_death
                   ,ctyzip_id
                   ,COUNT(case_number) AS total_covid_deaths
                   ,SUM(CASE WHEN nursing_home_ind = 'Y' THEN 1 ELSE 0 END) AS total_nursing_deaths  
              FROM final_project_covid_norm.covid_medical_info cov
              GROUP BY date_of_death,ctyzip_id
         ) cmi
	   ON CAST(sb.behv_date AS DATE) = CAST(cmi.date_of_death AS DATE)
	  AND  sb.ctyzip_id = cmi.ctyzip_id
  ;

#################################################
### FACTS Table 2 covid_measure
### Calculated Measure 1 - Total survey count per zip,race,age_grp from survey table
### Calculated Measure 2 - Total covid death  per zip,race,age_grp from covid medical archive table
### Calculated Measure 3 - Total nursing home death per zip,race,age_grp from covid medical archive table
### Other Measures like median income and population count are from census data
### Census Population count is by race and zip . Our facts includes age-grp . So with the assumption all age-grp,race has the same median income and population, performed join
################################################
TRUNCATE TABLE final_project_covid_dw.facts_covid_measure;
INSERT INTO final_project_covid_dw.facts_covid_measure
SELECT DISTINCT
       loc.location_key
      ,rc.race_key
      ,ag.age_grp_key
	  /*,loc.ctyzip_id
      ,rc.race_id
      ,ag.age_grp_id*/
      ,cenag.median_income
      ,cenag.population_count
      ,CASE WHEN svy.total_survey_count IS NULL THEN 0 ELSE svy.total_survey_count END AS total_survey_count
      ,CASE WHEN mif.total_deaths IS NULL THEN 0 ELSE mif.total_deaths END AS total_deaths
      ,CASE WHEN mif.total_nursing_home_deaths IS NULL THEN 0 ELSE mif.total_nursing_home_deaths  END AS total_nursing_home_deaths 
FROM ( SELECT cen.census_id,
              cen.ctyzip_id,
              cen.race_id,
              cen.median_income,
              cen.population_count
			,ag.age_grp_id
		FROM final_project_covid_norm.census cen,
             final_project_covid_dw.dim_age_group ag
	  ) cenag
LEFT JOIN (SELECT  ctyzip_id
			       ,race_id
                   ,age_grp_id
                   ,COUNT(case_number) AS total_deaths
                   ,SUM(CASE WHEN nursing_home_ind = 'Y' THEN 1 ELSE 0 END) AS total_nursing_home_deaths  
		      FROM final_project_covid_norm.covid_medical_info cov
              GROUP BY ctyzip_id,race_id,age_grp_id
          ) mif
      ON mif.ctyzip_id  = cenag.ctyzip_id
	 AND mif.race_id  = cenag.race_id
     AND mif.age_grp_id  = cenag.age_grp_id 
INNER JOIN final_project_covid_dw.dim_location loc
        ON cenag.ctyzip_id = loc.ctyzip_id
LEFT JOIN final_project_covid_dw.dim_race rc
        ON cenag.race_id = rc.race_id
LEFT JOIN final_project_covid_dw.dim_age_group ag
        ON cenag.age_grp_id = ag.age_grp_id
LEFT JOIN (SELECT  sur.ctyzip_id
				  ,sur.race_id
				  ,sur.age_grp_id
				  ,COUNT(sur.survey_id) AS total_survey_count
		      FROM final_project_covid_norm.survey sur
              INNER JOIN final_project_covid_dw.dim_location loc1
                      ON sur.ctyzip_id = loc1.ctyzip_id
              GROUP BY ctyzip_id,race_id,age_grp_id
          ) svy
      ON svy.ctyzip_id  = cenag.ctyzip_id
	 AND svy.race_id  = cenag.race_id
     AND svy.age_grp_id  = cenag.age_grp_id 
;