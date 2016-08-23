create database if not exists `kubikvest` character set utf8 collate utf8_general_ci;

use kubikvest;

DROP TABLE IF EXISTS `user`;

CREATE TABLE `user` (
  `userId` bigint(20) unsigned NOT NULL,
  `accessToken` varchar(255) DEFAULT NULL,
  `kvestId` int(10) unsigned,
  `pointId` int(10) unsigned
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


insert user (userId, accessToken) value (1111,'asdasd');
