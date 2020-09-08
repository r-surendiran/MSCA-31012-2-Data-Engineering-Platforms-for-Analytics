/***********************************************
**                MSc ANALYTICS 
**     DATA ENGINEERING PLATFORMS (MSCA 31012-2)
** File:   Final Project Snowflake DDL 
** Desc:   DDL for the Final Project Snowflake Dimensional model
** Auth:   Team 1
** Date:   05/24/2020
** ALL RIGHTS RESERVED | DO NOT DISTRIBUTE
************************************************/

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL,ALLOW_INVALID_DATES';

DROP DATABASE IF EXISTS `final_project_covid_dw` ;
CREATE DATABASE  IF NOT EXISTS `final_project_covid_dw` 
/*!40100 DEFAULT CHARACTER SET utf8 */ /*!80016 DEFAULT ENCRYPTION='N' */;
USE `final_project_covid_dw`;

#################################################
## Dimension table 1 dim_age_grp              ###
#################################################
DROP TABLE IF EXISTS final_project_covid_dw.dim_age_group;
CREATE TABLE IF NOT EXISTS `final_project_covid_dw`.`dim_age_group` (
  `age_grp_key` BIGINT  NOT NULL AUTO_INCREMENT,
  `age_grp_last_update` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `age_grp_id` INT(10) NOT NULL,
  `age_grp_yr` VARCHAR(45) NOT NULL,
  `age_grp_nbr` VARCHAR(45) NOT NULL,
  `age_grp_gen` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`age_grp_key`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1;

CREATE INDEX `age_grp_last_update_idx` ON `final_project_covid_dw`.`dim_age_group` (`age_grp_last_update` ASC);

#################################################
## Dimension table 2 dim_race                 ###
#################################################
#######DDL#####################
DROP TABLE IF EXISTS final_project_covid_dw.dim_race;
CREATE TABLE IF NOT EXISTS `final_project_covid_dw`.`dim_race` (
  `race_key` BIGINT  NOT NULL AUTO_INCREMENT,
  `race_last_update` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `race_id` INT(10) NOT NULL,
  `race_name` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`race_key`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1;

CREATE INDEX `race_last_update_idx` ON `final_project_covid_dw`.`dim_race` (`race_last_update` ASC);
      
#################################################
## Dimension table 3 dim_location             ###
#################################################
DROP TABLE IF EXISTS final_project_covid_dw.dim_location;
CREATE TABLE IF NOT EXISTS `final_project_covid_dw`.`dim_location` (
  `location_key` BIGINT NOT NULL AUTO_INCREMENT,
  `location_last_update` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `ctyzip_id` BIGINT NOT NULL ,
  `zip` INT(6) NOT NULL,
  `fips` VARCHAR(10) NOT NULL, 
  `city` VARCHAR(50) NOT NULL,
  `state` VARCHAR(40) NOT NULL, 
  `cty_nm` VARCHAR(50) NOT NULL,
  `total_cases` INT DEFAULT 0,
  `total_tested` INT DEFAULT 0 ,
  `nursing_home_cases` INT DEFAULT 0,
  `nursing_home_deaths` INT DEFAULT 0,
  PRIMARY KEY (`location_key`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1;

CREATE INDEX `location_last_update_idx` ON `final_project_covid_dw`.`dim_location` (`location_last_update` ASC);

#################################################
## Outrigger Dimension table 3A dim_loc_cases  ###
#################################################
/*DROP TABLE IF EXISTS final_project_covid_dw.dim_loc_cases;
CREATE TABLE IF NOT EXISTS `final_project_covid_dw`.`dim_loc_cases` (
  `case_key` BIGINT NOT NULL AUTO_INCREMENT,
  `location_key` BIGINT NOT NULL,
  `loc_cases_last_update` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `total_cases` INT ,
  `total_tested` INT ,
  `nursing_home_cases` INT ,
  `nursing_home_deaths` INT,
  PRIMARY KEY (`case_key`),
  CONSTRAINT `loc_case_location_fk`
  FOREIGN KEY (`location_key`)
  REFERENCES `final_project_covid_dw`.`dim_location` (`location_key`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1;

CREATE INDEX `loc_cases_last_update_idx` ON `final_project_covid_dw`.`dim_loc_cases` (`loc_cases_last_update` ASC);
CREATE INDEX `loc_cases_location_idx` ON `final_project_covid_dw`.`dim_loc_cases` (`location_key` ASC);
*/
#################################################
## Outrigger Dimension table 3B dim_nursing_homes ###
#################################################
DROP TABLE IF EXISTS final_project_covid_dw.dim_loc_nursing;
CREATE TABLE IF NOT EXISTS `final_project_covid_dw`.`dim_loc_nursing` (
  `nursing_key` BIGINT NOT NULL AUTO_INCREMENT,
  `location_key` BIGINT NOT NULL,
  `loc_nursing_last_update` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `facility_name` VARCHAR(150) NOT NULL ,
  `address_ln_1` VARCHAR(80) NOT NULL ,
  `address_ln_2` VARCHAR(40) NULL ,
  `nursing_cases` INT DEFAULT 0,
  `nursing_deaths` INT DEFAULT 0,
  PRIMARY KEY (`nursing_key`),
  CONSTRAINT `loc_case_nursing_fk`
  FOREIGN KEY (`location_key`)
  REFERENCES `final_project_covid_dw`.`dim_location` (`location_key`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1;

CREATE INDEX `loc_nursing_last_update_idx` ON `final_project_covid_dw`.`dim_loc_nursing` (`loc_nursing_last_update` ASC);
CREATE INDEX `loc_nursing_location_idx` ON `final_project_covid_dw`.`dim_loc_nursing` (`location_key` ASC);

#################################################
## Outrigger Dimension table 3B dim_nursing_homes ###
#################################################
DROP TABLE IF EXISTS final_project_covid_dw.dim_survey;
CREATE TABLE IF NOT EXISTS `final_project_covid_dw`.`dim_survey` (
  `survey_key` BIGINT NOT NULL AUTO_INCREMENT,
  `location_key` BIGINT NOT NULL,
  `loc_survey_last_update` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `generation` VARCHAR(14) NOT NULL,
  `ethnicity`  VARCHAR(30) NOT NULL, 
  `gender`     VARCHAR(10),
  `education_lvl`  VARCHAR(175) NULL, 
  `income_bracket`  VARCHAR(175) NULL,
  `health_insurance` INT(1) DEFAULT '0',
  `read_news` INT(1) DEFAULT '0',
  `covid_test` INT(1) DEFAULT '0',
  `high_risk` INT(1) DEFAULT '0',
  `problem` VARCHAR(100) NULL,
  `hosp_visit` INT(1) DEFAULT '0',
  `adeq_care` INT(1) DEFAULT '0',
  `overwh_hosp` INT(1) DEFAULT '0',
  PRIMARY KEY (`survey_key`),
  CONSTRAINT `loc_survey_fk`
  FOREIGN KEY (`location_key`)
  REFERENCES `final_project_covid_dw`.`dim_location` (`location_key`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1;

CREATE INDEX `loc_survey_last_update_idx` ON `final_project_covid_dw`.`dim_survey` (`loc_survey_last_update` ASC);
CREATE INDEX `loc_survey_location_idx` ON `final_project_covid_dw`.`dim_survey` (`location_key` ASC);

#################################################
## Dimension table 4 dim_date                 ###
#################################################
#######DDL#####################
DROP TABLE IF EXISTS final_project_covid_dw.dim_date;
CREATE TABLE IF NOT EXISTS `final_project_covid_dw`.`dim_date` (
  `date_id` BIGINT NOT NULL,
  `date_val` DATE NOT NULL,
  `timestamp` BIGINT(20) NULL DEFAULT NULL,
  `weekend` CHAR(10) NOT NULL DEFAULT 'Weekday',
  `day_of_week` CHAR(10) NULL,
  `month` CHAR(10)  NULL,
  `month_day` INT(11) NULL,
  `year` INT(11) NULL,
  PRIMARY KEY (`date_id`),
  UNIQUE INDEX `date_val` (`date_val` ASC),
  INDEX `year_week` (`year` ASC))
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1;

LOCK TABLES `dim_date` WRITE;
/*!40000 ALTER TABLE `dim_date` DISABLE KEYS */;
/*!40000 ALTER TABLE `dim_date` ENABLE KEYS */;
UNLOCK TABLES;

#################################################
## Staging table 4a numbers                   ###
#################################################
DROP TABLE IF EXISTS final_project_covid_dw.numbers;

CREATE TABLE IF NOT EXISTS `final_project_covid_dw`.`numbers` (
  `number` BIGINT(20) NULL DEFAULT NULL)
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1;

#################################################
## Staging table 4a numbers_small             ###
#################################################
DROP TABLE IF EXISTS final_project_covid_dw.numbers_small;

CREATE TABLE IF NOT EXISTS `final_project_covid_dw`.`numbers_small` (
  `number` INT(11) NULL DEFAULT NULL)
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1;

#################################################
## Table 5 : Social Behaviour FACTS TABLE     ###
#################################################

DROP TABLE IF EXISTS final_project_covid_dw.facts_social_behavior;
CREATE TABLE `final_project_covid_dw`.`facts_social_behavior` (
`location_key` BIGINT NOT NULL,
`behv_date_key` BIGINT  NOT NULL,
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
`count_hour0` BIGINT NOT NULL DEFAULT 0,
`count_hour1` BIGINT NOT NULL DEFAULT 0,
`count_hour2` BIGINT NOT NULL DEFAULT 0,
`count_hour3` BIGINT NOT NULL DEFAULT 0,
`count_hour4` BIGINT NOT NULL DEFAULT 0,
`count_hour5` BIGINT NOT NULL DEFAULT 0,
`count_hour6` BIGINT NOT NULL DEFAULT 0,
`count_hour7` BIGINT NOT NULL DEFAULT 0,
`count_hour8` BIGINT NOT NULL DEFAULT 0,
`count_hour9` BIGINT NOT NULL DEFAULT 0,
`count_hour10` BIGINT NOT NULL DEFAULT 0,
`count_hour11` BIGINT NOT NULL DEFAULT 0,
`count_hour12` BIGINT NOT NULL DEFAULT 0,
`count_hour13` BIGINT NOT NULL DEFAULT 0,
`count_hour14` BIGINT NOT NULL DEFAULT 0,
`count_hour15` BIGINT NOT NULL DEFAULT 0,
`count_hour16` BIGINT NOT NULL DEFAULT 0,
`count_hour17` BIGINT NOT NULL DEFAULT 0,
`count_hour18` BIGINT NOT NULL DEFAULT 0,
`count_hour19` BIGINT NOT NULL DEFAULT 0,
`count_hour20` BIGINT NOT NULL DEFAULT 0,
`count_hour21` BIGINT NOT NULL DEFAULT 0,
`count_hour22` BIGINT NOT NULL DEFAULT 0,
`count_hour23` BIGINT NOT NULL DEFAULT 0,
`total_covid_deaths` BIGINT NULL DEFAULT 0,
`total_nursing_deaths` BIGINT NULL DEFAULT 0,
  CONSTRAINT `socialbehvdw_ctyzip_fk`
  FOREIGN KEY (`location_key`)
  REFERENCES `final_project_covid_dw`.`dim_location` (`location_key`),
  CONSTRAINT `socialbehvdw_behv_date_fk`
  FOREIGN KEY (`behv_date_key`)
  REFERENCES `final_project_covid_dw`.`dim_date` (`date_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8
;

CREATE INDEX `facts1_behv_date_idx` ON `final_project_covid_dw`.`facts_social_behavior` (`behv_date_key` ASC);
CREATE INDEX `facts1_location_idx` ON `final_project_covid_dw`.`facts_social_behavior` (`location_key` ASC);

#################################################
## Table 5 : Covid Cases FACTS(2) TABLE     ###
#################################################

DROP TABLE IF EXISTS final_project_covid_dw.facts_covid_measure;
CREATE TABLE `final_project_covid_dw`.`facts_covid_measure` (
`location_key` BIGINT NOT NULL,
`race_key` BIGINT  NOT NULL,
`age_grp_key` BIGINT  NOT NULL,
`median_income` BIGINT NOT NULL,
`population_count` BIGINT NOT NULL,
`total_survey_count` BIGINT NULL DEFAULT 0,
`total_deaths` BIGINT NULL DEFAULT 0,
`total_nursing_home_deaths` BIGINT NULL DEFAULT 0,
  CONSTRAINT `facts_coviddw_location_fk`
  FOREIGN KEY (`location_key`)
  REFERENCES `final_project_covid_dw`.`dim_location` (`location_key`),
  CONSTRAINT `facts_coviddw_race_fk`
  FOREIGN KEY (`race_key`)
  REFERENCES `final_project_covid_dw`.`dim_race` (`race_key`),
  CONSTRAINT `facts_coviddw_agegrp_fk`
  FOREIGN KEY (`age_grp_key`)
  REFERENCES `final_project_covid_dw`.`dim_age_group` (`age_grp_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8
;

CREATE INDEX `facts2_age_grp_idx` ON `final_project_covid_dw`.`facts_covid_measure` (`age_grp_key` ASC);
CREATE INDEX `facts2_race_idx` ON `final_project_covid_dw`.`facts_covid_measure` (`race_key` ASC);
CREATE INDEX `facts2_location_idx` ON `final_project_covid_dw`.`facts_covid_measure` (`location_key` ASC);

##select * from INFORMATION_SCHEMA.TABLE_CONSTRAINTS where CONSTRAINT_TYPE = 'FOREIGN KEY' AND CONSTRAINT_SCHEMA = 'final_project_covid_dw';