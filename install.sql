CREATE TABLE `dutylogs` (
	`key` BIGINT(20) NOT NULL AUTO_INCREMENT,
	`name` VARCHAR(200) NULL DEFAULT NULL COLLATE 'utf8mb3_unicode_ci',
	`id` VARCHAR(200) NULL DEFAULT NULL COLLATE 'utf8mb3_unicode_ci',
	`dept` VARCHAR(200) NULL DEFAULT NULL COLLATE 'utf8mb3_unicode_ci',
	`time` INT(20) UNSIGNED NULL DEFAULT NULL,
	`lastclockin` VARCHAR(100) NULL DEFAULT NULL COLLATE 'utf8mb3_unicode_ci',
	`type` TINYTEXT NULL DEFAULT NULL COLLATE 'utf8mb3_unicode_ci',
	PRIMARY KEY (`key`) USING BTREE
)
COLLATE='utf8mb3_unicode_ci'
ENGINE=InnoDB
AUTO_INCREMENT=32160
;

CREATE TABLE `activedutyunits` (
	`discord` TEXT NULL DEFAULT NULL COLLATE 'utf8mb4_general_ci',
	`id` TEXT NULL DEFAULT NULL COLLATE 'utf8mb4_general_ci',
	`name` TEXT NULL DEFAULT NULL COLLATE 'utf8mb4_general_ci',
	`dpt` TEXT NULL DEFAULT NULL COLLATE 'utf8mb4_general_ci',
	`onDutySince` TEXT NULL DEFAULT NULL COLLATE 'utf8mb4_general_ci'
)
COLLATE='utf8mb4_general_ci'
ENGINE=InnoDB
;