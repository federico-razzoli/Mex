/*
	Sequence Storage Engine Examples
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
	This file contains Examples & Experiments on the Labels used in Stored Programs.
	Labels are used to identify portions of code, and are referred by LEAVE and ITERATE.
*/



CREATE DATABASE IF NOT EXISTS `test`;
USE `test`;



/*
 *	LABEL.001 - Redefining Labels
 *	=============================
 */

 
 -- This example produces an error!!
 -- 1309: Redefining label abc
 
 
DELIMITER ||

DROP PROCEDURE IF EXISTS `tsp1`;
CREATE PROCEDURE `tsp1`()
BEGIN
	DECLARE `x` TINYINT UNSIGNED DEFAULT 1;
	
	`abc`:
	WHILE `x` < 3 DO
		SELECT 'outer: looping';
		`abc`:
		LOOP
			SELECT 'inner: looping';
			LEAVE `abc`;
		END LOOP;
		SELECT 'inner: out of loop';
		SET `x` = `x` + 1;
	END WHILE;
	SELECT 'outer: out of loop';
END;

||
DELIMITER ;



/*
 *	LABELS.002 - Caller / Callee 's Labels
 *	======================================
 */


-- This example produces an error!!
-- 1308: LEAVE with no matching label: abc
-- This shows that a callee routine cannot LEAVE a caller's label.


DELIMITER ||

DROP PROCEDURE IF EXISTS `tsp2`;
CREATE PROCEDURE `tsp2`()
BEGIN
	`def`:
	LOOP
		SELECT 'tsp2: looping';
		LEAVE `abc`;
	END LOOP;
	SELECT 'tsp2: out of loop';
END;

DROP PROCEDURE IF EXISTS `tsp1`;
CREATE PROCEDURE `tsp1`()
BEGIN
	DECLARE `x` TINYINT UNSIGNED DEFAULT 1;
	`abc`:
	WHILE `x` < 3 DO
		SELECT 'tsp1: looping';
		CALL `tsp2`();
		SET `x` = `x` + 1;
	END WHILE;
	SELECT 'tsp1: out of loop';
END;

||
DELIMITER ;



/*
 *	LABELS.003 - Name "conflicts"
 *	=============================
 */


-- This example shows that it is possible for a caller and a callee
-- to contain labels with the same name.
-- LABELS.002 example shows that a callee routine can't LEAVE a caller's label,
-- so of course the "inner" label is exited.


DELIMITER ||

DROP PROCEDURE IF EXISTS `tsp2`;
CREATE PROCEDURE `tsp2`()
BEGIN
	`abc`:
	LOOP
		SELECT 'tsp2: looping';
		LEAVE `abc`;
	END LOOP;
	SELECT 'tsp2: out of loop';
END;

DROP PROCEDURE IF EXISTS `tsp1`;
CREATE PROCEDURE `tsp1`()
BEGIN
	DECLARE `x` TINYINT UNSIGNED DEFAULT 1;
	`abc`:
	WHILE `x` < 3 DO
		SELECT 'tsp1: looping';
		CALL `tsp2`();
		SET `x` = `x` + 1;
	END WHILE;
	SELECT 'tsp1: out of loop';
END;

||
DELIMITER ;



/*
 *	LABELS.004 - Multiple Labels
 *	============================
 */


-- This example produces an error!!
-- 1064 (generic syntax error)
-- This shows that 2 labels cannot refer to the same loop.


DELIMITER ||

DROP PROCEDURE IF EXISTS `tsp1`;
CREATE PROCEDURE `tsp1`()
BEGIN
	`abc`:
	`def`:
	LOOP
		SELECT 'looping';
		LEAVE `abc`;
	END LOOP;
	SELECT 'out of loop';
END;

||
DELIMITER ;

