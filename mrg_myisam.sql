/*
	MariaDB Experiments & Examples Examples
	Copyright Federico Razzoli  2013
	
	This file is part of MEX (MariaDB EXamples & EXperiments).
	
	MEX is free software: you can redistribute it and/or modify
	it under the terms of the GNU Affero General Public License as published by
	the Free Software Foundation, version 3 of the License.
	
	MEX is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU Affero General Public License for more details.
	
	You should have received a copy of the GNU Affero General Public License
	along with MEX.  If not, see <http://www.gnu.org/licenses/>.
*/


/*
	This file contains Examples & Experiments on the MRG_MyISAM Storage Engine.
*/



CREATE DATABASE IF NOT EXISTS `test`;
USE `test`;



/*
 *	MRG_MYISAM.001 - Alias
 *	======================
 */


-- This example shows that a MRG_MyISAM table can be built
-- on 1 MyISAM table and be just an alias.


DELIMITER ||

DROP TABLE IF EXISTS `t_base`;
CREATE TABLE `t_base`
(
	`c` TINYINT UNSIGNED NULL
)
	ENGINE = MyISAM;


-- t_alias is an alias for t_base
DROP TABLE IF EXISTS `t_alias`;
CREATE TABLE `t_alias`
(
	`c` TINYINT UNSIGNED NULL
)
	ENGINE = MRG_MyISAM,
	UNION = (`t_base`),
	INSERT_METHOD = LAST;


/*
 *	MRG_MYISAM.002 - Read-Only Alias
 *	================================
 */


-- This example shows that a MRG_MyISAM table can be
-- used as a read-only alias.


DROP TABLE IF EXISTS `t_base`;
CREATE TABLE `t_base`
(
	`c` TINYINT UNSIGNED NULL
)
	ENGINE = MyISAM;


-- this alias is read-only
DROP TABLE IF EXISTS `t_alias`;
CREATE TABLE `t_alias`
(
	`c` TINYINT UNSIGNED NULL
)
	ENGINE = MRG_MyISAM,
	UNION = (`t_base`),
	INSERT_METHOD = NO;


-- donald_duck cannot directly access t_base,
-- and since t_alias is read-only, he has no way to insert data
REVOKE ALL ON TABLE `t_base` FROM `donald_duck`;


/*
 *	MRG_MYISAM.003 - Triggers
 *	=========================
 */


-- These examples show that if you INSERT into a MRG_MyISAM table,
-- underlying tables triggers are not activated, and vice versa.


DELIMITER ||

DROP TABLE IF EXISTS `t_log`;
CREATE TABLE `t_log`
(
	`tab` CHAR(20) NOT NULL,
	`act` CHAR(10) NOT NULL,
	`c` TINYINT UNSIGNED NULL
)
	ENGINE = MyISAM;


-- INSERT


DROP TRIGGER IF EXISTS `trg_bi_t_base`;
CREATE TRIGGER `trg_bi_t_base`
	BEFORE INSERT
	ON `t_base`
	FOR EACH ROW
BEGIN
	INSERT INTO `t_log`
			(`tab`, `act`, `c`)
		VALUES
			('t_base', 'BI', NEW.c);
END;

DROP TRIGGER IF EXISTS `trg_ai_t_base`;
CREATE TRIGGER `trg_ai_t_base`
	AFTER INSERT
	ON `t_base`
	FOR EACH ROW
BEGIN
	INSERT INTO `t_log`
			(`tab`, `act`, `c`)
		VALUES
			('t_base', 'AI', NEW.c);
END;


DROP TRIGGER IF EXISTS `trg_bi_t_alias`;
CREATE TRIGGER `trg_bi_t_alias`
	BEFORE INSERT
	ON `t_alias`
	FOR EACH ROW
BEGIN
	INSERT INTO `t_log`
			(`tab`, `act`, `c`)
		VALUES
			('t_alias', 'BI', NEW.c);
END;

DROP TRIGGER IF EXISTS `trg_ai_t_alias`;
CREATE TRIGGER `trg_ai_t_alias`
	AFTER INSERT
	ON `t_alias`
	FOR EACH ROW
BEGIN
	INSERT INTO `t_log`
			(`tab`, `act`, `c`)
		VALUES
			('t_alias', 'AI', NEW.c);
END;


-- DELETE


DROP TRIGGER IF EXISTS `trg_bd_t_base`;
CREATE TRIGGER `trg_bd_t_base`
	BEFORE DELETE
	ON `t_base`
	FOR EACH ROW
BEGIN
	INSERT INTO `t_log`
			(`tab`, `act`, `c`)
		VALUES
			('t_base', 'BD', OLD.c);
END;

DROP TRIGGER IF EXISTS `trg_ad_t_base`;
CREATE TRIGGER `trg_ad_t_base`
	AFTER DELETE
	ON `t_base`
	FOR EACH ROW
BEGIN
	INSERT INTO `t_log`
			(`tab`, `act`, `c`)
		VALUES
			('t_base', 'AD', OLD.c);
END;


DROP TRIGGER IF EXISTS `trg_bd_t_alias`;
CREATE TRIGGER `trg_bd_t_alias`
	BEFORE DELETE
	ON `t_alias`
	FOR EACH ROW
BEGIN
	INSERT INTO `t_log`
			(`tab`, `act`, `c`)
		VALUES
			('t_alias', 'BD', OLD.c);
END;

DROP TRIGGER IF EXISTS `trg_ad_t_alias`;
CREATE TRIGGER `trg_ad_t_alias`
	AFTER DELETE
	ON `t_alias`
	FOR EACH ROW
BEGIN
	INSERT INTO `t_log`
			(`tab`, `act`, `c`)
		VALUES
			('t_alias', 'AD', OLD.c);
END;


-- UPDATE


DROP TRIGGER IF EXISTS `trg_bu_t_base`;
CREATE TRIGGER `trg_bu_t_base`
	BEFORE UPDATE
	ON `t_base`
	FOR EACH ROW
BEGIN
	INSERT INTO `t_log`
			(`tab`, `act`, `c`)
		VALUES
			('t_base', 'BU', OLD.c);
END;

DROP TRIGGER IF EXISTS `trg_au_t_base`;
CREATE TRIGGER `trg_au_t_base`
	AFTER UPDATE
	ON `t_base`
	FOR EACH ROW
BEGIN
	INSERT INTO `t_log`
			(`tab`, `act`, `c`)
		VALUES
			('t_base', 'AU', OLD.c);
END;


DROP TRIGGER IF EXISTS `trg_bu_t_alias`;
CREATE TRIGGER `trg_bu_t_alias`
	BEFORE UPDATE
	ON `t_alias`
	FOR EACH ROW
BEGIN
	INSERT INTO `t_log`
			(`tab`, `act`, `c`)
		VALUES
			('t_alias', 'BU', OLD.c);
END;

DROP TRIGGER IF EXISTS `trg_au_t_alias`;
CREATE TRIGGER `trg_au_t_alias`
	AFTER UPDATE
	ON `t_alias`
	FOR EACH ROW
BEGIN
	INSERT INTO `t_log`
			(`tab`, `act`, `c`)
		VALUES
			('t_alias', 'AU', OLD.c);
END;

||
DELIMITER ;


/*
 *	MRG_MYISAM.004 - Virtual Columns
 *	================================
 */


-- MRG_MyISAM tables can be based on MyISAM tables having Virtual Columns.
-- Limitations:
-- Virtual Columns must be PERSISTENT
-- Even when Virtual Columns expression can't produce NULL, MRG_MyISAM columns must be NULLable


DROP TABLE IF EXISTS `t_base`;
CREATE TABLE `t_base`
(
	`c` TINYINT UNSIGNED NULL,
	`v` TINYINT UNSIGNED GENERATED ALWAYS AS (`c` + 10) PERSISTENT
)
	ENGINE = MyISAM;


DROP TABLE IF EXISTS `t_alias`;
CREATE TABLE `t_alias`
(
	`c` TINYINT UNSIGNED NULL,
	`v` TINYINT UNSIGNED NULL
)
	ENGINE = MRG_MyISAM,
	UNION = (`t_base`),
	INSERT_METHOD = LAST;

