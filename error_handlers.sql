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
	This file contains Examples & Experiments on the error HANDLERs and CONDITIONs.
	All the statements can easily be adapted to particular use cases.
*/



/*
 *	ERR_HANDLERS.001 - Handling errors in CONTINUE HANDLERs
 *	===================================================
 */


-- This experiment shows that HANDLERs can handle errors which occur in a CONTINUE HANDLER
-- which is in the same procedure.
-- You can modify this Procedure by swapping the position of the HANDLERs to show that
-- the order doesn't matter.


DROP PROCEDURE IF EXISTS `t`;
CREATE PROCEDURE `t`()
BEGIN
	DECLARE `eof` BOOL;
	DECLARE `val` TEXT;
	
	DECLARE `crs` CURSOR FOR
		SELECT `SCHEMA_NAME` FROM `information_schema`.`SCHEMATA`;
	
	DECLARE EXIT HANDLER
		FOR 1326
	BEGIN
		SELECT 1326;
	END;
	
	DECLARE CONTINUE HANDLER
		FOR 1329
	BEGIN
		SELECT 1329;
		CLOSE `crs`;
	END;
	
	OPEN `crs`;
	
	`lp`: LOOP
		FETCH `crs` INTO `val`;
	END LOOP;
END;



/*
 *	ERR_HANDLERS.002 - Errors in EXIT HANDLERs
 *	======================================
 */


-- This experiment shows that HANDLERs can NOT handle errors which occur in a EXIT HANDLER,
-- unless it is in a caller procedure.


DROP PROCEDURE IF EXISTS `t`;
CREATE PROCEDURE `t`()
BEGIN
	DECLARE `eof` BOOL;
	DECLARE `val` TEXT;
	
	DECLARE `crs` CURSOR FOR
		SELECT `SCHEMA_NAME` FROM `information_schema`.`SCHEMATA`;
	
	DECLARE EXIT HANDLER
		FOR 1326
	BEGIN
		SELECT 1326;
	END;
	
	DECLARE EXIT HANDLER
		FOR 1329
	BEGIN
		SELECT 1329;
		CLOSE `crs`;
	END;
	
	OPEN `crs`;
	
	`lp`: LOOP
		FETCH `crs` INTO `val`;
	END LOOP;
END;



/*
 *	ERR_HANDLERS.003 - EXIT HANDLERs in different BEGIN..ENDs
 *	=====================================================
 */


-- This experiment shows how to use HANDLERs in outer blocks to handle
-- errors from inner blocks.


DROP PROCEDURE IF EXISTS `t`;
CREATE PROCEDURE `t`()
BEGIN
	DECLARE `crs` CURSOR FOR
		SELECT 1;
	
	DECLARE CONTINUE HANDLER
		FOR 1326
	BEGIN
		SELECT 1326;
	END;
	
	BEGIN
		DECLARE CONTINUE HANDLER
			FOR 1326
		BEGIN
			SELECT 1326;
		END;
		
		CLOSE `crs`;
	END;
	
	SELECT 'end';
END;



/*
 *	ERR_HANDLERS.004 - No endless loops
 *	===============================
 */


-- This experiment shows that HANDLERs don't recursively call themselves.


DROP PROCEDURE IF EXISTS `t`;
CREATE PROCEDURE `t`()
BEGIN
	DECLARE `crs` CURSOR FOR
		SELECT 1;
	
	DECLARE CONTINUE HANDLER
		FOR 1326
	BEGIN
		SELECT 1326;
		CLOSE `crs`;
	END;
	
	CLOSE `crs`;
END;



/*
 *	ERR_HANDLERS.005 - Unhandled CONDITIONs
 *	===================================
 */


-- Unhandled CONDITIONs don't produce any warning.


DROP PROCEDURE IF EXISTS `t`;
CREATE PROCEDURE `t`()
BEGIN
	DECLARE `cond` CONDITION FOR 1326;
	SELECT 1;
END;



/*
 *	ERR_HANDLERS.006 - Duplicate CONDITIONs
 *	===================================
 */


-- Duplicate CONDITIONs don't produce any warning.


DROP PROCEDURE IF EXISTS `t`;
CREATE PROCEDURE `t`()
BEGIN
	DECLARE `cond1` CONDITION FOR 1326;
	DECLARE `cond2` CONDITION FOR 1326;
	SELECT 1;
END;

