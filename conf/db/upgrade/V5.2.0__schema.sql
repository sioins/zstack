ALTER TABLE `zstack`.`HostNetworkInterfaceVO` MODIFY COLUMN `mac` varchar(128) DEFAULT NULL;

CREATE TABLE IF NOT EXISTS `zstack`.`XmlHookVO` (
    `uuid` varchar(32) NOT NULL UNIQUE,
    `name` varchar(255) UNIQUE NOT NULL,
    `description` varchar(2048) NULL,
    `type` varchar(32) NOT NULL,
    `hookScript` text NOT NULL,
    `libvirtVersion` varchar(32) DEFAULT NULL,
    `lastOpDate` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `createDate` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
    PRIMARY KEY  (`uuid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `zstack`.`XmlHookVmInstanceRefVO` (
    `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
    `xmlHookUuid` varchar(32) NOT NULL,
    `vmInstanceUuid` varchar(32) NOT NULL,
    `lastOpDate` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `createDate` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
    PRIMARY KEY (`id`),
    UNIQUE KEY `id` (`id`),
    KEY `fkXmlHookVmInstanceRefVOXmlHookVO` (`xmlHookUuid`),
    KEY `fkXmlHookVmInstanceRefVOVmInstanceVO` (`vmInstanceUuid`),
    CONSTRAINT `fkXmlHookVmInstanceRefVO` FOREIGN KEY (`xmlHookUuid`) REFERENCES `XmlHookVO` (`uuid`) ON DELETE CASCADE,
    CONSTRAINT `fkXmlHookVmInstanceRefVO1` FOREIGN KEY (`vmInstanceUuid`) REFERENCES `ResourceVO` (`uuid`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `zstack`.`SSOServerTokenVO`(
    `uuid` varchar(32) not null unique,
    `accessToken` text DEFAULT NULL,
    `idToken` text DEFAULT NULL,
    `refreshToken` text DEFAULT NULL,
    `userUuid` varchar(32) DEFAULT NULL,
    `lastOpDate` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00' ON UPDATE CURRENT_TIMESTAMP,
    `createDate` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
    PRIMARY KEY  (`uuid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP PROCEDURE IF EXISTS migrateJsonLabelToXmlHookVO;
DELIMITER $$
CREATE PROCEDURE migrateJsonLabelToXmlHookVO()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE hookUuid VARCHAR(32);
    DECLARE vmUuid VARCHAR(32);
    DECLARE hookValue TEXT;
    DECLARE cur CURSOR FOR SELECT DISTINCT REPLACE(labelKey,'user-defined-xml-hook-script-',''),labelValue FROM zstack.JsonLabelVO WHERE labelKey like 'user-defined-xml-hook-script-%%';
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    OPEN cur;
    read_loop: LOOP
        FETCH cur INTO vmUuid, hookValue;
        IF done THEN
            LEAVE read_loop;
        END IF;

        IF NOT EXISTS(SELECT * from XmlHookVO where hookScript = hookValue) THEN
            SET hookUuid = (REPLACE(UUID(), '-', ''));

            INSERT zstack.ResourceVO(uuid, resourceName, resourceType, concreteResourceType)
            VALUES (hookUuid, 'xml-hook', 'XmlHookVO', 'org.zstack.header.tag.XmlHookVO');

            INSERT zstack.XmlHookVO (uuid, name, description, type, hookScript, lastOpDate, createDate)
            VALUES(hookUuid, concat('xml-hook', hookUuid), 'xml-hook', 'Customization', hookValue, NOW(), NOW());

            INSERT zstack.XmlHookVmInstanceRefVO(xmlHookUuid, vmInstanceUuid, lastOpDate, createDate)
            VALUES (hookUuid, vmUuid, NOW(), NOW());

        ELSEIF NOT EXISTS(SELECT * from XmlHookVmInstanceRefVO where vmInstanceUuid = vmUuid) THEN
            SET hookUuid = (select uuid from XmlHookVO where hookScript = hookValue);
            INSERT zstack.XmlHookVmInstanceRefVO(xmlHookUuid, vmInstanceUuid, lastOpDate, createDate)
            VALUES (hookUuid, vmUuid, NOW(), NOW());
        END IF;

        DELETE FROM zstack.JsonLabelVO WHERE labelKey = CONCAT('user-defined-xml-hook-script-', vmUuid) AND labelValue = hookValue;
    END LOOP;
    CLOSE cur;

    SELECT CURTIME();
END $$
DELIMITER ;
call migrateJsonLabelToXmlHookVO();
DROP PROCEDURE IF EXISTS migrateJsonLabelToXmlHookVO;

DELETE b FROM HostNetworkInterfaceLldpVO b LEFT JOIN ResourceVO a ON b.uuid = a.uuid WHERE a.uuid IS NULL;

ALTER TABLE BareMetal2InstanceProvisionNicVO MODIFY mac varchar(17) NULL;

CREATE TABLE IF NOT EXISTS `zstack`.`GuestVmScriptEO` (
    `uuid` VARCHAR(32) NOT NULL UNIQUE,
    `name` VARCHAR(256) NOT NULL,
    `description` VARCHAR(256),
    `platform` VARCHAR(255) NOT NULL,
    `scriptContent` MEDIUMTEXT,
    `renderParams` MEDIUMTEXT,
    `scriptType` VARCHAR(32) NOT NULL,
    `scriptTimeout` INT UNSIGNED NOT NULL,
    `version` INT UNSIGNED NOT NULL,
    `deleted` VARCHAR(255) DEFAULT NULL,
    `lastOpDate` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00' ON UPDATE CURRENT_TIMESTAMP,
    `createDate` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
    PRIMARY KEY (`uuid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP VIEW IF EXISTS `zstack`.`GuestVmScriptVO`;
CREATE VIEW `zstack`.`GuestVmScriptVO` AS SELECT uuid, name, description, platform, scriptContent, renderParams, scriptType, scriptTimeout, version, createDate, lastOpDate FROM `zstack`.`GuestVmScriptEO` WHERE deleted IS NULL;

CREATE TABLE IF NOT EXISTS `zstack`.`GuestVmScriptExecutedRecordVO` (
    `uuid` VARCHAR(32) NOT NULL UNIQUE,
    `recordName` VARCHAR(255) NOT NULL,
    `scriptUuid` VARCHAR(32) NOT NULL,
    `scriptTimeout` INT UNSIGNED NOT NULL,
    `status` VARCHAR(256) NOT NULL,
    `version` INT UNSIGNED NOT NULL,
    `Executor` VARCHAR(256) NOT NULL ,
    `ExecutionCount` INT UNSIGNED NOT NULL,
    `scriptContent` MEDIUMTEXT,
    `renderParams` MEDIUMTEXT,
    `startTime` TIMESTAMP NOT NULL DEFAULT '0000-00-00 00:00:00',
    `endTime` TIMESTAMP NOT NULL DEFAULT '0000-00-00 00:00:00',
    PRIMARY KEY (`uuid`),
    INDEX `idxScriptUuid` (`scriptUuid`, `version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `zstack`.`GuestVmScriptExecutedRecordDetailVO` (
    `recordUuid` VARCHAR(32) NOT NULL,
    `vmInstanceUuid` VARCHAR(32) NOT NULL,
    `vmName` VARCHAR(255) NOT NULL,
    `status` VARCHAR(128) NOT NULL,
    `exitCode` INT UNSIGNED,
    `stdout` MEDIUMTEXT,
    `errCause` MEDIUMTEXT,
    `stderr` MEDIUMTEXT,
    `startTime` TIMESTAMP NOT NULL DEFAULT '0000-00-00 00:00:00',
    `endTime` TIMESTAMP NOT NULL DEFAULT '0000-00-00 00:00:00',
    PRIMARY KEY (`recordUuid`, `vmInstanceUuid`),
    CONSTRAINT `fkGuestVmScriptExecutedRecordDetailVOScriptExecutedRecordVO` FOREIGN KEY (`recordUuid`) REFERENCES `GuestVmScriptExecutedRecordVO` (`uuid`) ON DELETE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=utf8;

CALL ADD_COLUMN('SanSecSecretResourcePoolVO', 'managementIp', 'VARCHAR(128)', 1, NULL);
CALL ADD_COLUMN('SanSecSecretResourcePoolVO', 'port', 'int unsigned', 1, NULL);
CALL ADD_COLUMN('SanSecSecretResourcePoolVO', 'username', 'VARCHAR(128)', 1, NULL);
CALL ADD_COLUMN('SanSecSecretResourcePoolVO', 'password', 'VARCHAR(128)', 1, NULL);
CALL ADD_COLUMN('SanSecSecretResourcePoolVO', 'sm3Key', 'VARCHAR(128)', 1, NULL);
CALL ADD_COLUMN('SanSecSecretResourcePoolVO', 'sm4Key', 'VARCHAR(128)', 1, NULL);

ALTER TABLE `zstack`.`AuditsVO` MODIFY COLUMN requestDump MEDIUMTEXT, MODIFY COLUMN responseDump MEDIUMTEXT;

update EventSubscriptionVO set name = 'VM NIC IP Changed (GuestTools Is Required)' where uuid='98536fa94e3f4481a38331a989132b7c';
update EventSubscriptionVO set name = 'NIC IP Configured in VM has been Occupied or in the Reserved Range (GuestTools Is Required)' where uuid='4a3494bcdbac4eaab9e9e56e27d74a2a';

CALL ADD_COLUMN('MdevDeviceSpecVO', 'vendor', 'VARCHAR(128)', 1, NULL);

CALL ADD_COLUMN('BareMetal2ChassisGpuDeviceVO', 'isDriverLoaded', 'TINYINT(1)', 0, 0);
