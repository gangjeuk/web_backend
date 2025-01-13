-- MySQL Script generated by MySQL Workbench
-- Fri Jan 10 09:45:38 2025
-- Model: New Model    Version: 1.0
-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema tektonian
-- -----------------------------------------------------
DROP SCHEMA IF EXISTS `tektonian` ;

-- -----------------------------------------------------
-- Schema tektonian
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `tektonian` DEFAULT CHARACTER SET utf8 ;
USE `tektonian` ;

-- -----------------------------------------------------
-- Table `tektonian`.`User`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `tektonian`.`User` ;

CREATE TABLE IF NOT EXISTS `tektonian`.`User` (
  `user_id` BINARY(16) NOT NULL DEFAULT (uuid_to_bin(uuid())),
  `username` VARCHAR(64) NULL,
  `email` VARCHAR(255) NOT NULL,
  `created_at` DATETIME NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `image` VARCHAR(255) NULL,
  `nationality` VARCHAR(4) NULL,
  `working_country` VARCHAR(4) NULL,
  `roles` JSON NULL COMMENT 'To implement RBAC based access control, `roles` are needed.\n\nWe can filter unauthorized requests with role entity without querying database.\n\nOnce verification has been occurred user’s roles must be changed!!!!',
  PRIMARY KEY (`user_id`),
  UNIQUE INDEX `user_id_UNIQUE` (`user_id` ASC) VISIBLE);


-- -----------------------------------------------------
-- Table `tektonian`.`Account`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `tektonian`.`Account` ;

CREATE TABLE IF NOT EXISTS `tektonian`.`Account` (
  `user_id` BINARY(16) NOT NULL,
  `type` VARCHAR(255) NOT NULL,
  `provider` VARCHAR(255) NOT NULL,
  `providerAccountId` VARCHAR(255) NOT NULL,
  `refresh_token` VARCHAR(255) NULL,
  `access_token` VARCHAR(255) NULL,
  `expires_at` INT NULL,
  `token_type` VARCHAR(255) NULL,
  `scope` VARCHAR(255) NULL,
  `id_token` VARCHAR(2048) NULL,
  `session_state` VARCHAR(255) NULL,
  `password` VARCHAR(32) NULL,
  `salt` VARCHAR(7) NULL,
  PRIMARY KEY (`provider`, `providerAccountId`),
  INDEX `user_id_idx` (`user_id` ASC) VISIBLE,
  CONSTRAINT `fk_account_user_id`
    FOREIGN KEY (`user_id`)
    REFERENCES `tektonian`.`User` (`user_id`)
    ON DELETE CASCADE
    ON UPDATE NO ACTION);


-- -----------------------------------------------------
-- Table `tektonian`.`VerificationToken`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `tektonian`.`VerificationToken` ;

CREATE TABLE IF NOT EXISTS `tektonian`.`VerificationToken` (
  `identifier` VARCHAR(255) NOT NULL COMMENT 'User’s email address\nDidn’t set to foreign key but it is 1:N relationship.\nDue to users forgetting or failures during the sign-in flow, you might end up with unwanted rows in your database. You might want to periodically clean these up to avoid filling up your database with unnecessary data.',
  `token` VARCHAR(255) NOT NULL,
  `expires` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `token_type` VARCHAR(45) NOT NULL COMMENT 'Verification token can be used for various types of entities\n\nFor example: verification for corporation user, organization user, and student user \n\nSo there could be four types. \nnull: default type when user sign in\nstudent: when user verifies itself is student\norgz: ``\nCorp: ``',
  PRIMARY KEY (`identifier`, `token`));


-- -----------------------------------------------------
-- Table `tektonian`.`Corporation`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `tektonian`.`Corporation` ;

CREATE TABLE IF NOT EXISTS `tektonian`.`Corporation` (
  `corp_id` INT NOT NULL AUTO_INCREMENT,
  `corp_name` VARCHAR(255) NOT NULL,
  `nationality` VARCHAR(4) NOT NULL,
  `corp_domain` VARCHAR(255) NULL,
  `ceo_name` VARCHAR(255) NULL,
  `corp_address` VARCHAR(255) NULL,
  `phone_number` VARCHAR(255) NULL,
  `corp_num` BIGINT UNSIGNED NOT NULL,
  `biz_num` BIGINT UNSIGNED NULL,
  `biz_started_at` DATE NULL,
  `corp_status` TINYINT NULL,
  `biz_type` VARCHAR(255) NULL,
  `logo_image` VARCHAR(255) NULL,
  `site_url` VARCHAR(255) NULL,
  PRIMARY KEY (`corp_id`));


-- -----------------------------------------------------
-- Table `tektonian`.`Organization`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `tektonian`.`Organization` ;

CREATE TABLE IF NOT EXISTS `tektonian`.`Organization` (
  `orgn_id` INT NOT NULL AUTO_INCREMENT,
  `orgn_code` INT UNSIGNED NULL,
  `nationality` VARCHAR(4) NOT NULL,
  `full_name` VARCHAR(255) NOT NULL,
  `short_name` VARCHAR(255) NULL,
  `orgn_status` VARCHAR(255) NULL,
  `phone_number` VARCHAR(32) NULL,
  `site_url` VARCHAR(255) NULL,
  `orgn_type` VARCHAR(255) NULL,
  PRIMARY KEY (`orgn_id`));


-- -----------------------------------------------------
-- Table `tektonian`.`Consumer`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `tektonian`.`Consumer` ;

CREATE TABLE IF NOT EXISTS `tektonian`.`Consumer` (
  `consumer_id` INT NOT NULL AUTO_INCREMENT,
  `user_id` BINARY(16) NULL,
  `corp_id` INT NULL,
  `orgn_id` INT NULL,
  `consumer_type` VARCHAR(255) NOT NULL,
  `consumer_email` VARCHAR(255) NOT NULL,
  `consumer_verified` TIMESTAMP NULL DEFAULT NULL COMMENT 'Consumer can have three types \n\nnormal: normal user\ncorp: user works at corporation / so corporation entity can have multiple providers\norgn: user works at organization /  ``',
  `phone_number` VARCHAR(32) NOT NULL,
  `created_at` DATETIME NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`consumer_id`),
  INDEX `user_id_idx` (`user_id` ASC) VISIBLE,
  INDEX `corp_id_idx` (`corp_id` ASC) VISIBLE,
  INDEX `orgn_id_idx` (`orgn_id` ASC) VISIBLE,
  CONSTRAINT `user_id_fk`
    FOREIGN KEY (`user_id`)
    REFERENCES `tektonian`.`User` (`user_id`)
    ON DELETE SET NULL
    ON UPDATE NO ACTION,
  CONSTRAINT `corp_id_fk`
    FOREIGN KEY (`corp_id`)
    REFERENCES `tektonian`.`Corporation` (`corp_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `orgn_id_fk`
    FOREIGN KEY (`orgn_id`)
    REFERENCES `tektonian`.`Organization` (`orgn_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION);


-- -----------------------------------------------------
-- Table `tektonian`.`Student`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `tektonian`.`Student` ;

CREATE TABLE IF NOT EXISTS `tektonian`.`Student` (
  `student_id` INT NOT NULL AUTO_INCREMENT,
  `user_id` BINARY(16) NOT NULL,
  `name_glb` JSON NOT NULL,
  `birth_date` DATE NOT NULL,
  `email_verified` TIMESTAMP NULL DEFAULT NULL COMMENT 'email_verified field could be set if one of the `AcademicHistory` entity of students has been verified',
  `phone_number` VARCHAR(32) NOT NULL,
  `emergency_contact` VARCHAR(32) NOT NULL,
  `gender` TINYINT NOT NULL,
  `image` VARCHAR(255) NOT NULL DEFAULT '',
  `has_car` TINYINT NOT NULL DEFAULT 0,
  `keyword_list` JSON NOT NULL,
  `created_at` DATETIME NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`student_id`),
  INDEX `user_id_idx` (`user_id` ASC) VISIBLE,
  UNIQUE INDEX `user_id_UNIQUE` (`user_id` ASC) VISIBLE,
  CONSTRAINT `fk_student_user_id`
    FOREIGN KEY (`user_id`)
    REFERENCES `tektonian`.`User` (`user_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION);


-- -----------------------------------------------------
-- Table `tektonian`.`School`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `tektonian`.`School` ;

CREATE TABLE IF NOT EXISTS `tektonian`.`School` (
  `school_id` INT NOT NULL,
  `school_name` VARCHAR(255) NOT NULL,
  `school_name_glb` JSON NOT NULL,
  `country_code` VARCHAR(4) NOT NULL,
  `address` VARCHAR(255) NOT NULL,
  `coordinate` POINT NOT NULL COMMENT 'School can have multiple campus\n',
  `hompage_url` VARCHAR(255) NULL,
  `email_domain` VARCHAR(45) NULL,
  `phone_number` VARCHAR(45) NULL,
  PRIMARY KEY (`school_id`));


-- -----------------------------------------------------
-- Table `tektonian`.`AcademicHistory`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `tektonian`.`AcademicHistory` ;

CREATE TABLE IF NOT EXISTS `tektonian`.`AcademicHistory` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `school_id` INT NOT NULL,
  `student_id` INT NOT NULL,
  `degree` VARCHAR(255) NOT NULL,
  `start_date` DATE NOT NULL,
  `end_date` DATE NOT NULL,
  `status` TINYINT(2) NOT NULL,
  `faculty` VARCHAR(255) NOT NULL,
  `school_email` VARCHAR(255) NULL,
  `is_attending` TINYINT NULL DEFAULT 0 COMMENT 'Whether a student is attending a school now or not.\n\nIf a Student is connected to multiple AcademicHistory, only one is_attending should be set true.\n\nUser can have multiple AcademicHistory, but s/he must be attending only one school.\n\n',
  PRIMARY KEY (`id`),
  INDEX `school_id_idx` (`school_id` ASC) VISIBLE,
  INDEX `student_id_idx` (`student_id` ASC) VISIBLE,
  CONSTRAINT `fk_aca_school_id`
    FOREIGN KEY (`school_id`)
    REFERENCES `tektonian`.`School` (`school_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_aca_student_id`
    FOREIGN KEY (`student_id`)
    REFERENCES `tektonian`.`Student` (`student_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION);


-- -----------------------------------------------------
-- Table `tektonian`.`LanguageExam`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `tektonian`.`LanguageExam` ;

CREATE TABLE IF NOT EXISTS `tektonian`.`LanguageExam` (
  `exam_id` INT NOT NULL,
  `exam_name_glb` JSON NOT NULL,
  `exam_results` JSON NOT NULL COMMENT 'If a test is class type then the classes of a result of the test should be listed',
  `exam_type` VARCHAR(45) NULL,
  `lang_country_code` VARCHAR(4) NOT NULL,
  PRIMARY KEY (`exam_id`));


-- -----------------------------------------------------
-- Table `tektonian`.`ExamHistory`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `tektonian`.`ExamHistory` ;

CREATE TABLE IF NOT EXISTS `tektonian`.`ExamHistory` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `student_id` INT NOT NULL,
  `exam_id` INT NOT NULL,
  `level` INT NULL,
  PRIMARY KEY (`id`),
  INDEX `student_id_idx` (`student_id` ASC) VISIBLE,
  INDEX `exam_id_idx` (`exam_id` ASC) VISIBLE,
  CONSTRAINT `fk_his_student_id`
    FOREIGN KEY (`student_id`)
    REFERENCES `tektonian`.`Student` (`student_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_his_exam_id`
    FOREIGN KEY (`exam_id`)
    REFERENCES `tektonian`.`LanguageExam` (`exam_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION);


-- -----------------------------------------------------
-- Table `tektonian`.`Request`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `tektonian`.`Request` ;

CREATE TABLE IF NOT EXISTS `tektonian`.`Request` (
  `request_id` INT NOT NULL AUTO_INCREMENT,
  `consumer_id` INT NOT NULL,
  `title` VARCHAR(255) NOT NULL,
  `head_count` TINYINT UNSIGNED NOT NULL,
  `reward_price` INT NOT NULL,
  `currency` VARCHAR(2) NOT NULL,
  `content` TEXT NOT NULL,
  `are_needed` JSON NULL,
  `are_required` JSON NULL,
  `start_date` DATE NOT NULL,
  `end_date` DATE NOT NULL,
  `address` VARCHAR(255) NULL,
  `address_coordinate` POINT NULL,
  `provide_food` TINYINT(1) NOT NULL DEFAULT 0,
  `provide_trans_exp` TINYINT(1) NOT NULL DEFAULT 0,
  `prep_material` JSON NULL,
  `request_status` TINYINT NULL COMMENT 'There could be various statuses of a request.\n\nFor example\n\nPosted: consumer wrote a request but not paid\nPaid: consumer paid for a request\nOutdated: No provider(s) contracted with a consumer\nContracted: provider(s) contracted with a consumer\nFinished: work has been done!\nFailed: Contraction didn’t work properly\n',
  `start_time` TIME NOT NULL,
  `end_time` TIME NOT NULL,
  `created_at` DATETIME NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `corp_id` INT NULL COMMENT 'Have no idea that this field could be utilized late;;',
  `orgn_id` INT NULL COMMENT 'Have no idea that this field could be utilized late;;',
  PRIMARY KEY (`request_id`),
  INDEX `consumer_id_idx` (`consumer_id` ASC) VISIBLE,
  CONSTRAINT `consumer_id_fk`
    FOREIGN KEY (`consumer_id`)
    REFERENCES `tektonian`.`Consumer` (`consumer_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION);


-- -----------------------------------------------------
-- Table `tektonian`.`CorporationReview`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `tektonian`.`CorporationReview` ;

CREATE TABLE IF NOT EXISTS `tektonian`.`CorporationReview` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `consumer_id` INT NOT NULL,
  `student_id` INT NOT NULL,
  `corp_id` INT NOT NULL,
  `request_id` INT NOT NULL,
  `request_url` VARCHAR(255) NOT NULL,
  `review_text` TEXT NOT NULL,
  `prep_requirement` VARCHAR(255) NOT NULL,
  `sense_of_achive` TINYINT NOT NULL,
  `work_atmosphere` TINYINT NOT NULL,
  `created_at` DATETIME NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`));


-- -----------------------------------------------------
-- Table `tektonian`.`StudentReview`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `tektonian`.`StudentReview` ;

CREATE TABLE IF NOT EXISTS `tektonian`.`StudentReview` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `corp_id` INT NULL COMMENT 'Have no idea that this field could be utilized late;;',
  `orgn_id` INT NULL COMMENT 'Have no idea that this field could be utilized late;;',
  `consumer_id` INT NOT NULL,
  `student_id` INT NOT NULL,
  `request_id` INT NOT NULL,
  `request_url` VARCHAR(255) NOT NULL,
  `was_late` TINYINT NOT NULL,
  `was_proactive` TINYINT NOT NULL,
  `was_diligent` TINYINT NOT NULL,
  `commu_ability` TINYINT NOT NULL,
  `lang_fluent` TINYINT NOT NULL,
  `goal_fulfillment` TINYINT NOT NULL,
  `want_cowork` TINYINT NOT NULL,
  `praise` TEXT NOT NULL,
  `need_improve` TEXT NOT NULL,
  `created_at` DATETIME NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`));


-- -----------------------------------------------------
-- Table `tektonian`.`Provider`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `tektonian`.`Provider` ;

CREATE TABLE IF NOT EXISTS `tektonian`.`Provider` (
  `provider_id` INT NOT NULL AUTO_INCREMENT,
  `contracted_at` DATETIME NULL DEFAULT NULL,
  `request_attend_at` DATETIME NULL DEFAULT NULL,
  `attend_approved_at` DATETIME NULL DEFAULT NULL,
  `finish_job_at` DATETIME NULL DEFAULT NULL,
  `received_money_at` DATETIME NULL DEFAULT NULL,
  `provider_status` TINYINT NOT NULL DEFAULT 0,
  `student_id` INT NOT NULL,
  `user_id` BINARY(16) NOT NULL,
  `request_id` INT NOT NULL,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`provider_id`),
  INDEX `user_id_fk_idx` (`user_id` ASC) VISIBLE,
  INDEX `student_id_fk_idx` (`student_id` ASC) VISIBLE,
  INDEX `request_id_fk_idx` (`request_id` ASC) VISIBLE,
  CONSTRAINT `fk_provider_user_id`
    FOREIGN KEY (`user_id`)
    REFERENCES `tektonian`.`User` (`user_id`)
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT `student_id_fk`
    FOREIGN KEY (`student_id`)
    REFERENCES `tektonian`.`Student` (`student_id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `request_id_fk`
    FOREIGN KEY (`request_id`)
    REFERENCES `tektonian`.`Request` (`request_id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
