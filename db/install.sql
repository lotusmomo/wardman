/*
 * Project: Wardman System Database Schema
 * Author:  Hideo Suzumiya
 * Date:    2023-05-29
 * Version: 1.5
 * Email:   211302222 at yzu dot edu dot cn
 * Target:  MySQL 5.7.38
 */

-- 创建数据库
DROP DATABASE IF EXISTS `wardman`;
CREATE DATABASE `wardman` DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;
USE `wardman`;

-- 科室表
DROP TABLE IF EXISTS `department`;
CREATE TABLE `department` (
    `id`       INT(8)       NOT NULL AUTO_INCREMENT COMMENT '科室号',
    `name`     VARCHAR(255) NOT NULL COMMENT '科室名',
    `tel`      VARCHAR(11)  NOT NULL COMMENT '电话',
    `location` VARCHAR(255) NOT NULL COMMENT '地址',
    PRIMARY KEY (`id`)
);

-- 医生表
DROP TABLE IF EXISTS `doctor`;
CREATE TABLE `doctor` (
    `id`     INT(8)       NOT NULL AUTO_INCREMENT COMMENT '工号',
    `name`   VARCHAR(255) NOT NULL COMMENT '姓名',
    `gender` TINYINT(1)   NOT NULL COMMENT '性别 0-女 1-男',
    `tel`    VARCHAR(11)  NOT NULL COMMENT '电话',
    `dep`    INT(8)       NOT NULL COMMENT '科室',
    `ssn`    VARCHAR(18)  NOT NULL COMMENT '身份证号',
    `pass`   VARCHAR(255) NOT NULL COMMENT '密码',
    `online` TINYINT(1)   NOT NULL DEFAULT '1' COMMENT '是否在职',
    PRIMARY KEY (`id`),
    FOREIGN KEY (`dep`)   REFERENCES department(`id`)
);

-- 病房表
DROP TABLE IF EXISTS `ward`;
CREATE TABLE `ward` (
    `id`       INT(8)       NOT NULL AUTO_INCREMENT COMMENT '病房号',
    `dep`      INT(8)       NOT NULL COMMENT '科室',
    `location` VARCHAR(255) NOT NULL COMMENT '地址',
    PRIMARY KEY (`id`),
    FOREIGN KEY (`dep`) REFERENCES department(`id`)
);

-- 病床表
DROP TABLE IF EXISTS `bed`;
CREATE TABLE `bed` (
    `id`     INT(8)      NOT NULL AUTO_INCREMENT COMMENT '病床号',
    `ward`   INT(8)      NOT NULL COMMENT '病房号',
    `occupy` TINYINT(1)  NOT NULL DEFAULT '0' COMMENT '是否占用',
    PRIMARY KEY (`id`),
    FOREIGN KEY (`ward`) REFERENCES ward(`id`)
);

-- 病人表
DROP TABLE IF EXISTS `patient`;
CREATE TABLE `patient` (
    `ssn`    VARCHAR(18)  NOT NULL COMMENT '身份证号',
    `name`   VARCHAR(255) NOT NULL COMMENT '姓名',
    `gender` TINYINT(1)   NOT NULL COMMENT '性别 0-女 1-男',
    `tel`    VARCHAR(11)  NOT NULL COMMENT '电话',
    `blood`  VARCHAR(255) NOT NULL COMMENT '血型',
    `pass`   VARCHAR(255) NOT NULL COMMENT '密码',
    `online` TINYINT(1)   NOT NULL DEFAULT '0' COMMENT '在院 0-否 1-是',
    PRIMARY KEY (`ssn`)
);

-- 病历表
DROP TABLE IF EXISTS `treatment`;
CREATE TABLE `treatment` (
    `id`      INT(16)       NOT NULL AUTO_INCREMENT COMMENT '病历号',
    `content` TEXT          NOT NULL COMMENT '病历内容',
    `doc`     INT(8)        NOT NULL COMMENT '主治医生工号',
    `patient` VARCHAR(18)   NOT NULL COMMENT '病人身份证号',
    PRIMARY KEY (`id`),
    FOREIGN KEY (`doc`)     REFERENCES doctor(`id`),
    FOREIGN KEY (`patient`) REFERENCES patient(`ssn`)
);

-- 住院表
DROP TABLE IF EXISTS `checkin`;
CREATE TABLE `checkin` (
    `id`        INT(8)        NOT NULL AUTO_INCREMENT COMMENT '住院号',
    `bed`       INT(8)        NOT NULL COMMENT '病床号',
    `date`      TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '入院日期',
    `treatment` INT(16)       NOT NULL COMMENT '病历号',
    `fee`       FLOAT         NOT NULL COMMENT '住院费用/日',
    `online`    TINYINT(1)    NOT NULL DEFAULT '1' COMMENT '是否活动 0-否 1-是',
    PRIMARY KEY (`id`),
    FOREIGN KEY (`bed`)       REFERENCES bed(`id`),
    FOREIGN KEY (`treatment`) REFERENCES treatment(`id`)
);

-- 视图
DROP VIEW IF EXISTS `login_view`;
CREATE VIEW `login_view` AS 
    SELECT `id` AS `user`, `name`, `pass`, '1' AS `privilege` FROM doctor
    UNION
    SELECT `tel` AS user, `name`, `pass`, '0' AS `privilege` FROM patient;

DROP VIEW IF EXISTS `doctor_view`;
CREATE VIEW `doctor_view` AS
    SELECT 
    `doctor`.`id`, 
    `doctor`.`name`, 
    IF(`doctor`.`gender` = 1, '男', '女') AS `gender`,
    `doctor`.`tel`, 
    `doctor`.`ssn`, 
    IF(`doctor`.`online` = 1, '是', '否') AS `online`, 
    `department`.`name` AS `dname` 
    FROM 
    `doctor` JOIN `department`
        ON `doctor`.dep = `department`.id;

DROP VIEW IF EXISTS `patient_view`;
CREATE VIEW `patient_view` AS
    SELECT
    `patient`.`ssn`,
    `patient`.`name`,
    IF(`patient`.`gender` = 1, '男', '女') AS `gender`,
    `patient`.`tel`,
    `patient`.`blood`,
    IF(`patient`.`online` = 1, '在', '不在') AS `online`
    FROM
    `patient`;

DROP VIEW IF EXISTS `ward_view`;
CREATE VIEW `ward_view` AS
    SELECT
    `ward`.`id`,
    `department`.`name` AS `dname`,
    `ward`.`location`
    FROM
    `ward`
    JOIN
    `department` ON `ward`.`dep` = `department`.`id`;

DROP VIEW IF EXISTS `bed_view`;
CREATE VIEW `bed_view` AS
    SELECT
    `bed`.`id`,
    `bed`.`ward`,
    IF(`bed`.`occupy` = 1, '占用', '空闲') AS `occupy`
    FROM
    `bed`;

DROP VIEW IF EXISTS `treatment_view`;
CREATE VIEW `treatment_view` AS
    SELECT
    `treatment`.`id`,
    `treatment`.`content`,
    `doctor`.`name` AS `dname`,
    `patient`.`name` AS `pname`
    FROM
    `treatment`
    JOIN
    `doctor` ON `treatment`.`doc` = `doctor`.`id`
    JOIN
    `patient` ON `treatment`.`patient` = `patient`.`ssn`;

DROP VIEW IF EXISTS `checkin_view`;
CREATE VIEW `checkin_view` AS
    SELECT
    `checkin`.`id`,
    `bed`.`id` AS `bid`,
    `ward`.`id` AS `wid`,
    `department`.`name` AS `dname`,
    DATE(`checkin`.`date`) AS `date`,
    `treatment`.`id` AS `tid`,
    `patient`.`name` AS `pname`,
    `checkin`.`fee`,
    IF(`checkin`.`online` = 1, '是', '否') AS `online`
    FROM
    `checkin`
    JOIN
    `bed` ON `checkin`.`bed` = `bed`.`id`
    JOIN
    `ward` ON `bed`.`ward` = `ward`.`id`
    JOIN
    `department` ON `ward`.`dep` = `department`.`id`
    JOIN
    `treatment` ON `checkin`.`treatment` = `treatment`.`id`
    JOIN
    `patient` ON `treatment`.`patient` = `patient`.`ssn`;

-- 触发器-检查身份证号
-- 定义函数
DROP FUNCTION IF EXISTS `check_ssn`;
DELIMITER //
CREATE FUNCTION `check_ssn`(`ssn` VARCHAR(18))
    RETURNS enum('true','false')
    LANGUAGE SQL
    NOT DETERMINISTIC
    NO SQL
    SQL SECURITY INVOKER
    COMMENT '校验身份证号'
BEGIN
DECLARE status ENUM('true','false') default 'false';
DECLARE verify CHAR(1);
DECLARE sigma INT;
DECLARE remainder INT;
IF CHAR_LENGTH(ssn) = 18 THEN
    SET sigma = 
        CAST(SUBSTRING(ssn,1,1)  AS UNSIGNED) * 7 +
        CAST(SUBSTRING(ssn,2,1)  AS UNSIGNED) * 9 +
        CAST(SUBSTRING(ssn,3,1)  AS UNSIGNED) * 10 +
        CAST(SUBSTRING(ssn,4,1)  AS UNSIGNED) * 5 +
        CAST(SUBSTRING(ssn,5,1)  AS UNSIGNED) * 8 +
        CAST(SUBSTRING(ssn,6,1)  AS UNSIGNED) * 4 +
        CAST(SUBSTRING(ssn,7,1)  AS UNSIGNED) * 2 +
        CAST(SUBSTRING(ssn,8,1)  AS UNSIGNED) * 1 +
        CAST(SUBSTRING(ssn,9,1)  AS UNSIGNED) * 6 +
        CAST(SUBSTRING(ssn,10,1) AS UNSIGNED) * 3 +
        CAST(SUBSTRING(ssn,11,1) AS UNSIGNED) * 7 +
        CAST(SUBSTRING(ssn,12,1) AS UNSIGNED) * 9 +
        CAST(SUBSTRING(ssn,13,1) AS UNSIGNED) * 10 +
        CAST(SUBSTRING(ssn,14,1) AS UNSIGNED) * 5 +
        CAST(SUBSTRING(ssn,15,1) AS UNSIGNED) * 8 +
        CAST(SUBSTRING(ssn,16,1) AS UNSIGNED) * 4 +
        CAST(SUBSTRING(ssn,17,1) AS UNSIGNED) * 2;
    set remainder = MOD(sigma,11);
    set verify = case remainder
        when 0 then '1' when 1 then '0' when 2 then 'X' when 3 then '9'
        when 4 then '8' when 5 then '7' when 6 then '6' when 7 then '5'
        when 8 then '4' when 9 then '3' when 10 then '2' else '/' end;
END IF;
IF RIGHT(ssn,1) = verify THEN SET status = 'true';
END IF;
RETURN status;
END //
DELIMITER ;

-- 定义触发器
DROP TRIGGER IF EXISTS `trig_ssn_doctor`;
DELIMITER //
CREATE TRIGGER `trig_ssn_doctor`
    BEFORE INSERT ON `doctor`
    FOR EACH ROW
BEGIN
    IF check_ssn(NEW.ssn) = 'false' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '身份证号错误';
    END IF;
END //
DELIMITER ;
DROP TRIGGER IF EXISTS `trig_ssn_patient`;
DELIMITER //
CREATE TRIGGER `trig_ssn_patient`
    BEFORE INSERT ON `patient`
    FOR EACH ROW
BEGIN
    IF check_ssn(NEW.ssn) = 'false' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '身份证号错误';
    END IF;
END //
DELIMITER ;

-- 测试数据
INSERT INTO `department` (`name`, `tel`, `location`) VALUES
('第一外科', '13000000001', '1号楼');
INSERT INTO `department` (`name`, `tel`, `location`) VALUES
('第一内科', '13000000002', '2号楼');

INSERT INTO `doctor` (`name`, `tel`, `gender`, `ssn`, `pass`, `dep`) VALUES
('财前五郎', '13900000001', 1, '11010119900307109X', 'zaizen', '1');
INSERT INTO `doctor` (`name`, `tel`, `gender`, `ssn`, `pass`, `dep`) VALUES
('东贞藏',   '13900000001', 1, '110101199003078478', 'azuma', '1');
INSERT INTO `doctor` (`name`, `tel`, `gender`, `ssn`, `pass`, `dep`) VALUES
('里见修二', '13900000002', 1, '110101199003070994', 'satomi', '2');
INSERT INTO `doctor` (`name`, `tel`, `gender`, `ssn`, `pass`, `dep`) VALUES
('鸟',      '13900000003', 1, '110101199003078072', 'tori', '2');

INSERT INTO `ward` (`dep`, `location`) VALUES ('1', '1号楼');
INSERT INTO `ward` (`dep`, `location`) VALUES ('2', '2号楼');

INSERT INTO `bed` (`ward`) VALUES ('1');
INSERT INTO `bed` (`ward`) VALUES ('1');
INSERT INTO `bed` (`ward`) VALUES ('1');
INSERT INTO `bed` (`ward`) VALUES ('1');
INSERT INTO `bed` (`ward`) VALUES ('2');
INSERT INTO `bed` (`ward`) VALUES ('2');
INSERT INTO `bed` (`ward`) VALUES ('2');
INSERT INTO `bed` (`ward`) VALUES ('2');