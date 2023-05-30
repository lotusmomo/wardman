-- phpMyAdmin SQL Dump
-- version 5.2.0
-- https://www.phpmyadmin.net/
--
-- 主机： 10.10.2.28
-- 生成日期： 2023-05-29 21:49:32
-- 服务器版本： 5.7.38-log
-- PHP 版本： 7.4.30

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- 数据库： `wardman`
--

DELIMITER $$
--
-- 函数
--
CREATE DEFINER=`root`@`%` FUNCTION `check_ssn` (`ssn` VARCHAR(18)) RETURNS ENUM('true','false') CHARSET utf8 NO SQL SQL SECURITY INVOKER COMMENT '校验身份证号' BEGIN
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
END$$

CREATE DEFINER=`root`@`%` FUNCTION `generate_ssn` () RETURNS VARCHAR(18) CHARSET utf8 NO SQL SQL SECURITY INVOKER COMMENT '生成身份证号' BEGIN
DECLARE ssn VARCHAR(18) DEFAULT '';
DECLARE region_code VARCHAR(6);
DECLARE birth_date DATE;
DECLARE order_number INT;
DECLARE check_code CHAR(1);
DECLARE sigma INT;
DECLARE remainder INT;
DECLARE verify CHAR(1);
SET region_code = LPAD(FLOOR(RAND() * 34) + 1, 2, '0');
SET birth_date = DATE_ADD('1949-10-01', INTERVAL FLOOR(RAND() * 30240) DAY);
SET order_number = FLOOR(RAND() * 999);
SET ssn = CONCAT(region_code, DATE_FORMAT(birth_date, '%Y%m%d'), LPAD(order_number, 3, '0'));
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
SET remainder = MOD(sigma, 11);
SET verify = CASE remainder
    WHEN 0 THEN '1' WHEN 1 THEN '0' WHEN 2 THEN 'X' WHEN 3 THEN '9'
    WHEN 4 THEN '8' WHEN 5 THEN '7' WHEN 6 THEN '6' WHEN 7 THEN '5'
    WHEN 8 THEN '4' WHEN 9 THEN '3' WHEN 10 THEN '2' ELSE '/' END;
SET ssn = CONCAT(ssn, verify);
RETURN ssn;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- 表的结构 `bed`
--

CREATE TABLE `bed` (
  `id` int(8) NOT NULL COMMENT '病床号',
  `ward` int(8) NOT NULL COMMENT '病房号',
  `occupy` tinyint(1) NOT NULL DEFAULT '0' COMMENT '是否占用 0-否 1-是'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- 转存表中的数据 `bed`
--

INSERT INTO `bed` (`id`, `ward`, `occupy`) VALUES
(1, 1, 0),
(2, 1, 0),
(3, 1, 0),
(4, 1, 0),
(5, 2, 0),
(6, 2, 0),
(7, 2, 0),
(8, 2, 0);

-- --------------------------------------------------------

--
-- 替换视图以便查看 `bed_view`
-- （参见下面的实际视图）
--
CREATE TABLE `bed_view` (
`id` int(8)
,`ward` int(8)
,`occupy` varchar(2)
);

-- --------------------------------------------------------

--
-- 表的结构 `checkin`
--

CREATE TABLE `checkin` (
  `id` int(8) NOT NULL COMMENT '住院号',
  `bed` int(8) NOT NULL COMMENT '病床号',
  `date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '入院日期',
  `treatment` int(16) NOT NULL COMMENT '病历号',
  `fee` float NOT NULL COMMENT '住院费用/日',
  `online` tinyint(1) NOT NULL DEFAULT '1' COMMENT '是否活动 0-否 1-是'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- 转存表中的数据 `checkin`
--

INSERT INTO `checkin` (`id`, `bed`, `date`, `treatment`, `fee`, `online`) VALUES
(2, 4, '2023-05-29 13:10:16', 4, 200, 1);

-- --------------------------------------------------------

--
-- 替换视图以便查看 `checkin_view`
-- （参见下面的实际视图）
--
CREATE TABLE `checkin_view` (
`id` int(8)
,`bid` int(8)
,`wid` int(8)
,`dname` varchar(255)
,`date` date
,`tid` int(16)
,`pname` varchar(255)
,`fee` float
,`online` varchar(1)
);

-- --------------------------------------------------------

--
-- 表的结构 `department`
--

CREATE TABLE `department` (
  `id` int(8) NOT NULL COMMENT '科室号',
  `name` varchar(255) NOT NULL COMMENT '科室名',
  `tel` varchar(11) NOT NULL COMMENT '电话',
  `location` varchar(255) NOT NULL COMMENT '地址'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- 转存表中的数据 `department`
--

INSERT INTO `department` (`id`, `name`, `tel`, `location`) VALUES
(1, '第一外科', '13000000001', '1号楼'),
(2, '第一内科', '13000000002', '2号楼'),
(25, '病理科', '13000000097', '不知道');

-- --------------------------------------------------------

--
-- 表的结构 `doctor`
--

CREATE TABLE `doctor` (
  `id` int(8) NOT NULL COMMENT '工号',
  `name` varchar(255) NOT NULL COMMENT '姓名',
  `gender` tinyint(1) NOT NULL COMMENT '性别 0-女 1-男',
  `tel` varchar(11) NOT NULL COMMENT '电话',
  `dep` int(8) NOT NULL COMMENT '科室',
  `ssn` varchar(18) NOT NULL COMMENT '身份证号',
  `pass` varchar(255) NOT NULL COMMENT '密码',
  `online` tinyint(1) NOT NULL DEFAULT '1' COMMENT '在职 0-否 1-是'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- 转存表中的数据 `doctor`
--

INSERT INTO `doctor` (`id`, `name`, `gender`, `tel`, `dep`, `ssn`, `pass`, `online`) VALUES
(1, '财前五郎', 1, '13900000001', 1, '11010119900307109X', 'zaizen', 1),
(2, '东贞藏', 1, '13900000001', 1, '110101199003078478', 'azuma', 1),
(3, '里见修二', 1, '13900000002', 2, '110101199003070994', 'satomi', 1),
(4, '鸟', 1, '13900000003', 2, '110101199003078072', 'tori', 1),
(7, '大河内', 1, '13092016888', 25, '110101199003077977', 'dahenei', 1);

--
-- 触发器 `doctor`
--
DELIMITER $$
CREATE TRIGGER `trig_ssn_doctor` BEFORE INSERT ON `doctor` FOR EACH ROW BEGIN
    IF check_ssn(NEW.ssn) = 'false' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '身份证号错误';
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- 替换视图以便查看 `doctor_view`
-- （参见下面的实际视图）
--
CREATE TABLE `doctor_view` (
`id` int(8)
,`name` varchar(255)
,`gender` varchar(1)
,`tel` varchar(11)
,`ssn` varchar(18)
,`online` varchar(1)
,`dname` varchar(255)
);

-- --------------------------------------------------------

--
-- 替换视图以便查看 `login_view`
-- （参见下面的实际视图）
--
CREATE TABLE `login_view` (
`user` varchar(11)
,`name` varchar(255)
,`pass` varchar(255)
,`privilege` varchar(1)
);

-- --------------------------------------------------------

--
-- 表的结构 `patient`
--

CREATE TABLE `patient` (
  `ssn` varchar(18) NOT NULL COMMENT '身份证号',
  `name` varchar(255) NOT NULL COMMENT '姓名',
  `gender` tinyint(1) NOT NULL COMMENT '性别 0-女 1-男',
  `tel` varchar(11) NOT NULL COMMENT '电话',
  `blood` varchar(255) NOT NULL COMMENT '血型',
  `pass` varchar(255) NOT NULL COMMENT '密码',
  `online` tinyint(1) NOT NULL DEFAULT '0' COMMENT '在院 0-否 1-是'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- 转存表中的数据 `patient`
--

INSERT INTO `patient` (`ssn`, `name`, `gender`, `tel`, `blood`, `pass`, `online`) VALUES
('321081200305268439', 'gaoyang', 1, '13092016863', 'A', '123456', 1);

--
-- 触发器 `patient`
--
DELIMITER $$
CREATE TRIGGER `trig_ssn_patient` BEFORE INSERT ON `patient` FOR EACH ROW BEGIN
    IF check_ssn(NEW.ssn) = 'false' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '身份证号错误';
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- 替换视图以便查看 `patient_view`
-- （参见下面的实际视图）
--
CREATE TABLE `patient_view` (
`ssn` varchar(18)
,`name` varchar(255)
,`gender` varchar(1)
,`tel` varchar(11)
,`blood` varchar(255)
,`online` varchar(2)
);

-- --------------------------------------------------------

--
-- 表的结构 `treatment`
--

CREATE TABLE `treatment` (
  `id` int(16) NOT NULL COMMENT '病历号',
  `content` text NOT NULL COMMENT '病历内容',
  `doc` int(8) NOT NULL COMMENT '主治医生工号',
  `patient` varchar(18) NOT NULL COMMENT '病人身份证号'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- 转存表中的数据 `treatment`
--

INSERT INTO `treatment` (`id`, `content`, `doc`, `patient`) VALUES
(4, '发烧', 1, '321081200305268439');

-- --------------------------------------------------------

--
-- 替换视图以便查看 `treatment_view`
-- （参见下面的实际视图）
--
CREATE TABLE `treatment_view` (
`id` int(16)
,`content` text
,`dname` varchar(255)
,`pname` varchar(255)
);

-- --------------------------------------------------------

--
-- 表的结构 `ward`
--

CREATE TABLE `ward` (
  `id` int(8) NOT NULL COMMENT '病房号',
  `dep` int(8) NOT NULL COMMENT '科室',
  `location` varchar(255) NOT NULL COMMENT '地址'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- 转存表中的数据 `ward`
--

INSERT INTO `ward` (`id`, `dep`, `location`) VALUES
(1, 1, '1号楼101'),
(2, 2, '2号楼101'),
(3, 1, '1号楼102');

-- --------------------------------------------------------

--
-- 替换视图以便查看 `ward_view`
-- （参见下面的实际视图）
--
CREATE TABLE `ward_view` (
`id` int(8)
,`dname` varchar(255)
,`location` varchar(255)
);

-- --------------------------------------------------------

--
-- 视图结构 `bed_view`
--
DROP TABLE IF EXISTS `bed_view`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`%` SQL SECURITY DEFINER VIEW `bed_view`  AS SELECT `bed`.`id` AS `id`, `bed`.`ward` AS `ward`, if((`bed`.`occupy` = 1),'占用','空闲') AS `occupy` FROM `bed``bed`  ;

-- --------------------------------------------------------

--
-- 视图结构 `checkin_view`
--
DROP TABLE IF EXISTS `checkin_view`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`%` SQL SECURITY DEFINER VIEW `checkin_view`  AS SELECT `checkin`.`id` AS `id`, `bed`.`id` AS `bid`, `ward`.`id` AS `wid`, `department`.`name` AS `dname`, cast(`checkin`.`date` as date) AS `date`, `treatment`.`id` AS `tid`, `patient`.`name` AS `pname`, `checkin`.`fee` AS `fee`, if((`checkin`.`online` = 1),'是','否') AS `online` FROM (((((`checkin` join `bed` on((`checkin`.`bed` = `bed`.`id`))) join `ward` on((`bed`.`ward` = `ward`.`id`))) join `department` on((`ward`.`dep` = `department`.`id`))) join `treatment` on((`checkin`.`treatment` = `treatment`.`id`))) join `patient` on((`treatment`.`patient` = `patient`.`ssn`)))  ;

-- --------------------------------------------------------

--
-- 视图结构 `doctor_view`
--
DROP TABLE IF EXISTS `doctor_view`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`%` SQL SECURITY DEFINER VIEW `doctor_view`  AS SELECT `doctor`.`id` AS `id`, `doctor`.`name` AS `name`, if((`doctor`.`gender` = 1),'男','女') AS `gender`, `doctor`.`tel` AS `tel`, `doctor`.`ssn` AS `ssn`, if((`doctor`.`online` = 1),'是','否') AS `online`, `department`.`name` AS `dname` FROM (`doctor` join `department` on((`doctor`.`dep` = `department`.`id`)))  ;

-- --------------------------------------------------------

--
-- 视图结构 `login_view`
--
DROP TABLE IF EXISTS `login_view`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`%` SQL SECURITY DEFINER VIEW `login_view`  AS SELECT `doctor`.`id` AS `user`, `doctor`.`name` AS `name`, `doctor`.`pass` AS `pass`, '1' AS `privilege` FROM `doctor` union select `patient`.`tel` AS `user`,`patient`.`name` AS `name`,`patient`.`pass` AS `pass`,'0' AS `privilege` from `patient`  ;

-- --------------------------------------------------------

--
-- 视图结构 `patient_view`
--
DROP TABLE IF EXISTS `patient_view`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`%` SQL SECURITY DEFINER VIEW `patient_view`  AS SELECT `patient`.`ssn` AS `ssn`, `patient`.`name` AS `name`, if((`patient`.`gender` = 1),'男','女') AS `gender`, `patient`.`tel` AS `tel`, `patient`.`blood` AS `blood`, if((`patient`.`online` = 1),'在','不在') AS `online` FROM `patient``patient`  ;

-- --------------------------------------------------------

--
-- 视图结构 `treatment_view`
--
DROP TABLE IF EXISTS `treatment_view`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`%` SQL SECURITY DEFINER VIEW `treatment_view`  AS SELECT `treatment`.`id` AS `id`, `treatment`.`content` AS `content`, `doctor`.`name` AS `dname`, `patient`.`name` AS `pname` FROM ((`treatment` join `doctor` on((`treatment`.`doc` = `doctor`.`id`))) join `patient` on((`treatment`.`patient` = `patient`.`ssn`)))  ;

-- --------------------------------------------------------

--
-- 视图结构 `ward_view`
--
DROP TABLE IF EXISTS `ward_view`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`%` SQL SECURITY DEFINER VIEW `ward_view`  AS SELECT `ward`.`id` AS `id`, `department`.`name` AS `dname`, `ward`.`location` AS `location` FROM (`ward` join `department` on((`ward`.`dep` = `department`.`id`)))  ;

--
-- 转储表的索引
--

--
-- 表的索引 `bed`
--
ALTER TABLE `bed`
  ADD PRIMARY KEY (`id`),
  ADD KEY `ward` (`ward`);

--
-- 表的索引 `checkin`
--
ALTER TABLE `checkin`
  ADD PRIMARY KEY (`id`),
  ADD KEY `bed` (`bed`),
  ADD KEY `treatment` (`treatment`);

--
-- 表的索引 `department`
--
ALTER TABLE `department`
  ADD PRIMARY KEY (`id`);

--
-- 表的索引 `doctor`
--
ALTER TABLE `doctor`
  ADD PRIMARY KEY (`id`),
  ADD KEY `dep` (`dep`);

--
-- 表的索引 `patient`
--
ALTER TABLE `patient`
  ADD PRIMARY KEY (`ssn`);

--
-- 表的索引 `treatment`
--
ALTER TABLE `treatment`
  ADD PRIMARY KEY (`id`),
  ADD KEY `doc` (`doc`),
  ADD KEY `patient` (`patient`);

--
-- 表的索引 `ward`
--
ALTER TABLE `ward`
  ADD PRIMARY KEY (`id`),
  ADD KEY `dep` (`dep`);

--
-- 在导出的表使用AUTO_INCREMENT
--

--
-- 使用表AUTO_INCREMENT `bed`
--
ALTER TABLE `bed`
  MODIFY `id` int(8) NOT NULL AUTO_INCREMENT COMMENT '病床号', AUTO_INCREMENT=11;

--
-- 使用表AUTO_INCREMENT `checkin`
--
ALTER TABLE `checkin`
  MODIFY `id` int(8) NOT NULL AUTO_INCREMENT COMMENT '住院号', AUTO_INCREMENT=3;

--
-- 使用表AUTO_INCREMENT `department`
--
ALTER TABLE `department`
  MODIFY `id` int(8) NOT NULL AUTO_INCREMENT COMMENT '科室号', AUTO_INCREMENT=26;

--
-- 使用表AUTO_INCREMENT `doctor`
--
ALTER TABLE `doctor`
  MODIFY `id` int(8) NOT NULL AUTO_INCREMENT COMMENT '工号', AUTO_INCREMENT=8;

--
-- 使用表AUTO_INCREMENT `treatment`
--
ALTER TABLE `treatment`
  MODIFY `id` int(16) NOT NULL AUTO_INCREMENT COMMENT '病历号', AUTO_INCREMENT=5;

--
-- 使用表AUTO_INCREMENT `ward`
--
ALTER TABLE `ward`
  MODIFY `id` int(8) NOT NULL AUTO_INCREMENT COMMENT '病房号', AUTO_INCREMENT=7;

--
-- 限制导出的表
--

--
-- 限制表 `bed`
--
ALTER TABLE `bed`
  ADD CONSTRAINT `bed_ibfk_1` FOREIGN KEY (`ward`) REFERENCES `ward` (`id`);

--
-- 限制表 `checkin`
--
ALTER TABLE `checkin`
  ADD CONSTRAINT `checkin_ibfk_1` FOREIGN KEY (`bed`) REFERENCES `bed` (`id`),
  ADD CONSTRAINT `checkin_ibfk_2` FOREIGN KEY (`treatment`) REFERENCES `treatment` (`id`);

--
-- 限制表 `doctor`
--
ALTER TABLE `doctor`
  ADD CONSTRAINT `doctor_ibfk_1` FOREIGN KEY (`dep`) REFERENCES `department` (`id`);

--
-- 限制表 `treatment`
--
ALTER TABLE `treatment`
  ADD CONSTRAINT `treatment_ibfk_1` FOREIGN KEY (`doc`) REFERENCES `doctor` (`id`),
  ADD CONSTRAINT `treatment_ibfk_2` FOREIGN KEY (`patient`) REFERENCES `patient` (`ssn`);

--
-- 限制表 `ward`
--
ALTER TABLE `ward`
  ADD CONSTRAINT `ward_ibfk_1` FOREIGN KEY (`dep`) REFERENCES `department` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
